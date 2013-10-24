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

    Module = Struct.new(:name, :version, :git)
    Node = Struct.new(:name, :classes, :instances, :repetitions, :groupname)

    def initialize(modules, classes, nodes, simulation_id)
      @modules = modules
      @classes = classes
      @nodes = nodes
      @simulation_id = simulation_id
    end

    attr_accessor :modules, :classes, :nodes, :simulation_id

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
          modules.add(Module.new(m["name"], m["version"], m["git"]))
        end
        node_config["classes"].each do |c|
          classes.add(c)
        end
        groupname = node_config["simulation_class"].split('.').last
        nodes.push(Node.new(node_config["certname"], node_config["classes"], node["num_instances"], node["num_repetitions"], groupname))
      end

      sim_id = ENV['PUPPET_GATLING_SIM_ID'] # :(
      ScenarioConfig.new(modules.to_a, classes.to_a, nodes, sim_id)

    end

    def self.initialize_config(scenario_config_path)
      @config = parse scenario_config_path
    end

    def self.config_instance
      @config
    end
  end
end
end
end

############################################################################################
# END CONFIGURATION PARSER CLASS
############################################################################################


