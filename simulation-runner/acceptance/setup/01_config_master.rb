require 'set'
require 'json'

############################################################################################
# CONFIGURATION PARSER CLASS
############################################################################################
# Would really like to move this into a separate file, waiting for puppet-acceptance
# to support adding library paths.

module Puppet
module Gatling
module LoadTest
  class ScenarioConfig

    Module = Struct.new(:name, :version)
    Node = Struct.new(:name, :classes)

    def initialize(modules, classes, nodes)
      @modules = modules
      @classes = classes
      @nodes = nodes
    end

    attr_accessor :modules, :classes, :nodes

    def self.parse(scenario_config_path)
      scenario = JSON.parse(File.read(scenario_config_path))
      modules = Set.new
      classes = Set.new
      nodes = []

      scenario["nodes"].each do |node|
        node_config_path = File.join(File.dirname(File.expand_path(scenario_config_path)),
                                "..", "nodes", node["node_config"])
        node_config = JSON.parse(File.read(node_config_path))
        node_config["modules"].each do |m|
          modules.add(Module.new(m["name"], m["version"]))
        end
        node_config["classes"].each do |c|
          classes.add(c)
        end
        nodes.push(Node.new(node_config["certname"], node_config["classes"]))
      end

      ScenarioConfig.new(modules.to_a, classes.to_a, nodes)

    end
  end
end
end
end

############################################################################################
# END CONFIGURATION PARSER CLASS
############################################################################################

############################################################################################
# PE/OSS HELPER METHODS
############################################################################################
# These methods are used to distinguish between paths / user accounts / etc. required
# for PE vs OSS.  Should probably be refactored into a class hierarchy, with a parent
# class and child classes with the two different implementations.

def is_pe?
  ENV["IS_PE"] == "true"
end

def pe_rake_cmd
  'RAILS_ENV=production /opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile'
end

def user_puppet
  is_pe? ? "pe-puppet" : "puppet"
end

def path_auth_conf
  is_pe? ? "/etc/puppetlabs/puppet/auth.conf" : "/etc/puppet/auth.conf"
end

def pe_register_classes(host, classes)
  result = on host, "#{pe_rake_cmd} nodeclass:list"
  class_list = result.stdout.split

  classes.select {|c| ! (class_list.include?(c)) }.each do |c|
    on host, "#{pe_rake_cmd} nodeclass:add name=#{c}"
  end
end

def pe_register_nodes(host, nodes)
  result = on host, "#{pe_rake_cmd} node:list"
  node_list = result.stdout.split

  nodes.each do |n|
    step "Configuring node '#{n.name}'" do
      unless node_list.include?(n.name)
        on host, "#{pe_rake_cmd} node:add name=#{n.name}"
      end

      # First we reset the list of classes for the node to the default PE classes.
      # NOTE: eventually we probably need to move this list of initial classes
      # to a config file, because this assumes we'll only ever be doing testing
      # against PE.  (Although all of this stuff assumes we have at least the
      # dashboard and rake tasks.)
      on host, "#{pe_rake_cmd} node:classes name=#{n.name} classes=pe_compliance,pe_accounts,pe_mcollective"
      n.classes.each do |c|
        on host, "#{pe_rake_cmd} node:addclass name=#{n.name} class=#{c}"
      end

      # Here we'll just print out the final list of classes for the node so that
      # it's visible in the log.
      on host, "#{pe_rake_cmd} node:listclasses name=#{n.name}"
    end

  end
end

def foss_register_nodes(host, nodes)

  path_site_pp = "/etc/puppet/manifests/site.pp"

  # We basically "clear" the node registry by clearing out site.pp
  on host, "[ ! -f #{path_site_pp} ] || mv #{path_site_pp} #{path_site_pp}.bak"

  site_pp_content = ""

  nodes.each do |n|
    site_pp_content += "node '#{n.name}' {\n"
    n.classes.each do |c|
      site_pp_content += "\tinclude #{c}\n"
    end
    site_pp_content += "}\n\n"
  end

  create_remote_file(host, path_site_pp, site_pp_content)

  step "Print site.pp to log for validation / debugging purposes" do
    on host, "cat #{path_site_pp}"
    on host, "chown root:#{user_puppet} #{path_site_pp} && chmod 640 #{path_site_pp}"
  end

end

############################################################################################
# END PE/OSS HELPER METHODS
############################################################################################


############################################################################################
# HELPER METHODS
############################################################################################

def create_custom_auth_conf(host)
  authconf = %q{path /
auth any
allow *
}

# create custom auth.conf
  on host, "[ -f #{path_auth_conf} ] && mv #{path_auth_conf} #{path_auth_conf}.bak"
  create_remote_file(host, path_auth_conf, authconf)
  on host, "chown root:#{user_puppet} #{path_auth_conf} && chmod 640 #{path_auth_conf}"
end

def install_modules(host, modules)
  File.open("Puppetfile", "w") { |f|
    f.puts 'forge "http://forge.puppetlabs.com"'

    modules.each do |m|
      f.puts "mod \"#{m.name}\", \"#{m.version}\""
    end
  }

  # NOTE:
  #   We might want to add a proper dependency on this gem
  #   (Bundler?) instead of installing directly in this method.
  on master, "/opt/puppet/bin/gem install librarian-puppet"
  on master, "/opt/puppet/bin/librarian-puppet install --clean --verbose"

  File.delete("Puppetfile")
end

def register_classes(host, classes)
  # No class registration necessary for FOSS
  if (is_pe?)
    pe_register_classes(host, classes)
  end
end

def register_nodes(host, nodes)
  if (is_pe?)
    pe_register_nodes(host, nodes)
  else
    foss_register_nodes(host, nodes)
  end
end

def install_git_master(master)
  pkg_cmd = on master, "which yum || which apt-get || which zypper"
  unless pkg_cmd
    fail("Unable to determine Master's package manager")
  end
  
  if pkg_cmd.include?("zypper")
    pkg_cmd+=" install -y git"
  elsif pkg_cmd.include?("yum")
    pkg_cmd+=" -y install git"
  elsif pkg_cmd.include?("apt-get")
    pkg_cmd+=" -y install git-core"
  end
  on master, "#{pkg_cmd}"
end

############################################################################################
# END HELPER METHODS
############################################################################################


############################################################################################
# MAIN SCRIPT
############################################################################################

unless ENV.has_key?("IS_PE")
  fail("Must set environment variable 'IS_PE' to either true or false")
end

test_name = "Setup for Gatling Performance Run"
config = Puppet::Gatling::LoadTest::ScenarioConfig.parse(File.expand_path(File.join("../simulation-runner", ENV['PUPPET_GATLING_SIMULATION_CONFIG'])))

install_git_master(master)
create_custom_auth_conf(master)
install_modules(master, config.modules)
register_classes(master, config.classes)
register_nodes(master, config.nodes)
