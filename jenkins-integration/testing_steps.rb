module Puppet
  module PerformanceTest
    module Steps
      def self.cobbler_provision(settings)
        raise 'Puppet Master ipaddress is required for cobbler provisioning' unless settings[:master_ip]
        run 'cobbler_provision.sh', settings[:master_ip]
      end

      def self.install(settings)
        @puppet_version = settings[:step_arguments]
        run 'uninstall_pe.sh', settings[:puppet_master]
        write_systest_config_file(settings)
        run "install_#{@puppet_version}.sh", settings[:systest_config], settings[:ssh_keyfile]
      end

      def self.simulate(settings)
        sim_id = settings[:step_arguments]["id"]
        simulation = write_scenario_to_file(settings[:step_arguments]["scenario"], sim_id)

        run "restart_services_#{@puppet_version}.sh", settings[:systest_config], settings[:ssh_keyfile]
        run "classify_nodes_#{@puppet_version}.sh", simulation, settings[:systest_config], settings[:ssh_keyfile]
        run 'sbt.sh', sim_id, settings[:puppet_master], simulation
      end

      private
      def self.run(script, *args)
        args = args.join ' '
        puts "Running '#{script} #{args}'"

        script_file = "scripts/#{script}"
        raise "#{@puppet_version} is not a supported Puppet version" unless File.exists? script_file

        successful = system "bash -x #{script_file} #{args}"
        raise "Error running #{script}" unless successful
      end

      def self.write_systest_config_file(settings)
        # Dominic M: feeling extra dirty - temporary until job is moved to jenkins-enterprise
        ip = (settings[:master_ip].nil?) ? nil : "ip: #{settings[:master_ip]}"
        config = <<-EOS
          HOSTS:
            #{settings[:master_hostname]}:
              roles:
                - master
                - agent
                - dashboard
                - database
              platform: el-6-x86_64
              #{ip}
          CONFIG:
            consoleport: 443
        EOS

        File.open(settings[:systest_config], 'w') { |file| file.write(config) }
      end

      def self.write_scenario_to_file(scenario, id)
        filename = "#{id}.json"
        scenario_file = File.join(ENV['PWD'], "../simulation-runner/config/scenarios/#{filename}")
        File.open(scenario_file, 'w') { |file| file.write(JSON.pretty_generate(scenario)) }
        return filename
      end
    end
  end
end
