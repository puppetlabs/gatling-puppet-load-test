require 'puppet/gatling/config'

test_name "Install Puppet modules"

def install_librarian_puppet(host)
  gem = '/opt/puppetlabs/puppet/bin/gem'
  on(host, "#{gem} install librarian-puppet -v 2.2.0 --no-document")
  on(host, puppet_resource("package git ensure=installed"))
end

def generate_puppetfile(modules)
  modules
    .map { |mod| "mod '#{mod}'" }
    .insert(0, "forge 'https://forgeapi.puppetlabs.com'")
    .join("\n")
end

def run_librarian_puppet(host, environment, puppetfile)
  create_remote_file(host, "#{environment}/Puppetfile", puppetfile)
  librarian_puppet = '/opt/puppetlabs/puppet/bin/librarian-puppet'
  on(host, "cd #{environment} && #{librarian_puppet} install --clean --verbose")
end

def install_modules(host, modules)
  puppetfile_content = generate_puppetfile(modules)
  environments = on(host, puppet('config print environmentpath')).stdout.chomp

  environment = 'production'
  run_librarian_puppet(host, "#{environments}/#{environment}", puppetfile_content)
end

scenario_id = ENV['PUPPET_GATLING_SCENARIO']
modules = get_modules(get_node_configs(get_scenario(scenario_id)))
install_librarian_puppet(master)
install_modules(master, modules)
