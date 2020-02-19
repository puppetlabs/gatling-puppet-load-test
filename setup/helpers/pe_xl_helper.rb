# frozen_string_literal: true

module PeXlHelper

  require "beaker-hostgenerator"

  # define beaker roles for each host
  BEAKER_ROLE_MAP = { "master"            => %w[master dashboard],
                      "master_replica"    => "master",
                      "puppet_db"         => "database",
                      "puppet_db_replica" => "database",
                      "compiler_a"        => "compile_master",
                      "compiler_b"        => "compile_master",
                      "loadbalancer"      => "loadbalancer",
                      "metrics"           => "metric" }

  # Creates the Bolt inventory file (nodes.yaml) and
  # parameters file (params.json) for the specified hosts
  #
  # @author Bill Claytor
  #
  # @param [Array<Hash>] hosts The provisioned hosts
  # @param [String] output_dir The directory where the file should be written
  #
  # TODO: spec test(s)
  def self.create_pe_xl_bolt_files(hosts, pe_ver, output_dir)
    create_nodes_yaml(hosts, output_dir)
    create_params_json(hosts, pe_ver, output_dir)
    create_beaker_config(hosts, output_dir)
  end

  # Creates the Bolt inventory file (nodes.yaml) for the specified hosts
  #
  # @author Bill Claytor
  #
  # @param [Array<Hash>] hosts The provisioned hosts
  # @param [String] output_dir The directory where the file should be written
  #
  def self.create_nodes_yaml(hosts, output_dir)
    data = { "groups" => [
      { "name"   => "pe_xl_nodes",
        "config" => { "transport" => "ssh",
                      "ssh"       => { "host-key-check" => false,
                                       "user"           => "root" } } }
    ] }

    output_path = "#{File.expand_path(output_dir)}/nodes.yaml"

    data["groups"][0]["nodes"] = hosts.map { |h| { "name" => h[:hostname], "alias" => h[:role] } }

    puts "Writing #{output_path}"
    puts

    File.write(output_path, data.to_yaml)
  end

  # Creates the Bolt parameters file (params.json) for the specified hosts
  #
  # @author Bill Claytor
  #
  # @param [Array<Hash>] hosts The provisioned hosts
  # @param [String] output_dir The directory where the file should be written
  #
  def self.create_params_json(hosts, pe_ver, output_dir)
    master, = hosts.map { |host| host[:hostname] if host[:role] == "master" }.compact
    pdb, = hosts.map { |host| host[:hostname] if host[:role] == "puppet_db" }.compact
    master_replica, = hosts.map { |host| host[:hostname] if host[:role] == "master_replica" }.compact
    pdb_replica, = hosts.map { |host| host[:hostname] if host[:role] == "puppet_db_replica" }.compact
    compilers = hosts.map { |host| host[:hostname] if host[:role].include? "compiler" }.compact
    loadbalancer, = hosts.map { |host| host[:hostname] if host[:role] == "loadbalancer" }.compact

    dns_alt_names = ["puppet", master, loadbalancer]
    pool_address = loadbalancer || master

    pe_xl_params = {
      install: true,
      configure: true,
      upgrade: false,
      master_host: master,
      puppetdb_database_host: pdb,
      master_replica_host: master_replica,
      puppetdb_database_replica_host: pdb_replica,
      compiler_hosts: compilers,

      console_password: "puppetlabs",
      dns_alt_names: dns_alt_names,
      compiler_pool_address: pool_address,
      version: pe_ver
    }.compact

    params_json = JSON.pretty_generate(pe_xl_params)
    output_path = "#{File.expand_path(output_dir)}/params.json"

    puts
    puts "Writing #{output_path}"
    puts

    File.write(output_path, params_json)
  end


  def self.create_beaker_config(hosts, output_dir)
    beaker_os = "redhat7-64"

    beaker_roles = BEAKER_ROLE_MAP.keys

    # seed beaker roles
    hosts.each do |h|
      h[:beaker] = []
    end

    master = hosts.detect { |h| h[:role] == "master" }
    m_index = hosts.index(master)

    # Add beaker roles to host hashes in order to associate them with the correct
    # host when constucting the beaker-host-generator string.
    until beaker_roles.empty?
      role_found = 0
      role = beaker_roles.pop
      hosts.each do |h|
        if h[:role] == role
          h[:beaker] << BEAKER_ROLE_MAP[role]
          role_found += 1
        end
      end
      # assign unallocated database role to master
      hosts[m_index][:beaker] << BEAKER_ROLE_MAP[role] \
        if role_found.zero? && %w[puppet_db puppet_db_replica].include?(role)
    end

    hosts.each do |h|
      h[:beaker] = h[:beaker].flatten.uniq.join(",")
    end

    # Build beaker-hg string
    bhg = BeakerHostGenerator::Generator.new
    bhg_string = +""
    hosts.each do |h|
      options = ["hostname=#{h[:hostname]}"]
      options << "ports=\[2003\,7777\,80\]" if h[:role] == "metrics"

      bhg_string << beaker_os + h[:beaker] + ".{" + options.join("\,") + "}-"
    end
    bhg_string = bhg_string.chomp("-")
    beaker_yaml = bhg.generate(bhg_string, hypervisor: "none").to_yaml
    output_path = "#{File.expand_path(output_dir)}/beaker.cfg"

    puts
    puts "Writing #{output_path}"
    puts

    File.write(output_path, beaker_yaml)
  end

end
