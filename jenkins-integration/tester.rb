module Puppet
  module PerformanceTest
    class Tester
      SUPPORTED_STEPS = {
        "install"           => :install,
        "simulate"          => :simulate,
        "cobbler-provision" => :cobbler_provision
      }

      def initialize(settings)
        @settings = settings
      end

      def perform(step, arguments = nil)
        if !SUPPORTED_STEPS.keys.include? step
          raise "Unrecognized step \"#{step}\".\nSupported steps are: #{SUPPORTED_STEPS.keys}"
        end

        if arguments.nil?
          send(SUPPORTED_STEPS[step])
        else
          send(SUPPORTED_STEPS[step], arguments)
        end
      end

      def cobbler_provision()
        raise 'Puppet Master ipaddress is required for cobbler provisioning' unless @settings[:master_ip]
        run 'cobbler_provision.sh', @settings[:master_ip]
      end

      def install(arguments)
        @puppet_version = arguments
        run 'uninstall_pe.sh', @settings[:puppet_master]
        write_systest_config_file()
        run "install_#{@puppet_version}.sh", @settings[:systest_config], @settings[:ssh_keyfile]
      end

      def simulate(arguments)
        sim_id = arguments["id"]
        scenario = arguments["scenario"]
        if arguments['puppet_version']
          @puppet_version = arguments['puppet_version']
        end
        filename = write_scenario_to_file(sim_id, scenario)

        run "restart_services_#{@puppet_version}.sh", @settings[:systest_config], @settings[:ssh_keyfile]
        run "classify_nodes_#{@puppet_version}.sh", filename, @settings[:systest_config], @settings[:ssh_keyfile]
        run 'sbt.sh', sim_id, @settings[:puppet_master], filename, @settings[:sbtpath]
      end

      private
      def run(script, *args)
        args = args.join ' '
        puts "Running '#{script} #{args}'"

        script_file = "scripts/#{script}"
        raise "#{@puppet_version} is not a supported Puppet version" unless File.exists? script_file

        successful = system "bash -x #{script_file} #{args}"
        raise "Error running #{script}" unless successful
      end

      def write_systest_config_file()
        # Dominic M: feeling extra dirty - temporary until job is moved to jenkins-enterprise
        ip = (@settings[:master_ip].nil?) ? nil : "ip: #{@settings[:master_ip]}"
        config = <<-EOS
          HOSTS:
            #{@settings[:master_hostname]}:
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

        File.open(@settings[:systest_config], 'w') { |file| file.write(config) }
      end

      def write_scenario_to_file(id, scenario)
        filename = "#{id}.json"
        scenario_file = File.join(ENV['PWD'], "../simulation-runner/config/scenarios/#{filename}")
        File.open(scenario_file, 'w') { |file| file.write(JSON.pretty_generate(scenario)) }
        return filename
      end
    end
  end
end
