#!/usr/bin/env ruby

require 'set'
require 'json'

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
        node_config_path = File.join(File.dirname(File.absolute_path(scenario_config_path)),
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

config = Puppet::Gatling::LoadTest::ScenarioConfig.parse("../../config/scenarios/sample_scenario_config.json")

puts "Modules to install:"
config.modules.each { |m| puts "\t#{m.name} (version #{m.version})" }

puts ""

puts "Classes to register:"
config.classes.each { |c| puts "\t#{c}" }

puts ""

puts "Nodes to register:"
config.nodes.each do |n|
  puts "\tNode name: #{n.name}"
  puts "\tNode classes to register:"
  n.classes.each do |c|
    puts "\t\t#{c}"
  end
end
