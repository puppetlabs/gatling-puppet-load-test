# frozen_string_literal: true

# vim: set foldmethod=marker

require "spec_helper"
require "minitest/assertions"

class PerfRunHelperClass
  include PerfRunHelper
  include Minitest::Assertions
end

TEST_TIME_NOW = Time.now
TEST_TIMESTAMP = TEST_TIME_NOW.getutc.to_i
TEST_DIR = "test/dir"
TEST_ARCHIVE_ROOT = "#{TEST_DIR}/PERF_#{TEST_TIMESTAMP}"
TEST_JSON = "{'parameter': 'value'}"

# rubocop:disable Metrics/BlockLength
describe PerfRunHelperClass do
  let(:hosts) do
    [Beaker::Host.create("ip_master",
                         { platform: Beaker::Platform.new("centos-6.5-x86_64"),
                           role: "master" }, logger: @logger),
     Beaker::Host.create("ip_metric",
                         { platform: Beaker::Platform.new("centos-6.5-x86_64"),
                           role: "metric" }, logger: @logger),
     Beaker::Host.create("ip_compile_master_A",
                         { platform: Beaker::Platform.new("centos-6.5-x86_64"),
                           role: "compile_master" }, logger: @logger),
     Beaker::Host.create("ip_compile_master_B",
                         { platform: Beaker::Platform.new("centos-6.5-x86_64"),
                           role: "compile_master" }, logger: @logger),
     Beaker::Host.create("ip_database",
                         { platform: Beaker::Platform.new("centos-6.5-x86_64"),
                           role: "database" }, logger: @logger),
     Beaker::Host.create("ip_loadbalancer",
                         { platform: Beaker::Platform.new("centos-6.5-x86_64"),
                           role: "loadbalancer" }, logger: @logger)]
  end
  let(:perf_result_processes) do
    # rubocop:disable Metrics/LineLength
    {
      "1" => { cmd: "/opt/puppetlabs/puppet/bin/pxp-agent", avg_cpu: 1, avg_mem: 10_000 },
      "2" => { cmd: %w[/opt/puppetlabs/server/apps/postgresql/bin/postmaster
                       -D /opt/puppetlabs/server/data/postgresql/9.6/data
                       -c log_directory=/var/log/puppetlabs/postgresql].join(" "),
               avg_cpu: 2, avg_mem: 20_000 },
      "3" => { cmd: %w[/opt/puppetlabs/server/bin/java
                       -Xmx256m
                       -Xms256m
                       -XX:+PrintGCDetails
                       -XX:+PrintGCDateStamps
                       -Xloggc:/var/log/puppetlabs/puppetdb/puppetdb_gc.log
                       -XX:+UseGCLogFileRotation
                       -XX:NumberOfGCLogFiles=16
                       -XX:GCLogFileSize=64m
                       -Djava.security.egd=/dev/urandom
                       -XX:OnOutOfMemoryError=kill -9 %p
                       -cp /opt/puppetlabs/server/apps/puppetdb/puppetdb.jar clojure.main
                       -m puppetlabs.puppetdb.main
                       --config /etc/puppetlabs/puppetdb/conf.d
                       --bootstrap-config /etc/puppetlabs/puppetdb/bootstrap.cfg
                       --restart-file /opt/puppetlabs/server/data/puppetdb/restartcounter].join(" "),
               avg_cpu: 3, avg_mem: 30_000 },
      "4" => { cmd: %w[nginx: master process /opt/puppetlabs/server/bin/nginx
                       -c /etc/puppetlabs/nginx/nginx.conf].join(" "),
               avg_cpu: 4, avg_mem: 40_000 },
      "5" => { cmd: %w[/opt/puppetlabs/server/bin/java
                       -Xmx256m
                       -Xms256m
                       -XX:+PrintGCDetails
                       -XX:+PrintGCDateStamps
                       -Xloggc:/var/log/puppetlabs/console-services/console-services_gc.log
                       -XX:+UseGCLogFileRotation
                       -XX:NumberOfGCLogFiles=16
                       -XX:GCLogFileSize=64m
                       -Djava.security.egd=/dev/urandom
                       -XX:OnOutOfMemoryError=kill -9 %p
                       -cp /opt/puppetlabs/server/apps/console-services/console-services-release.jar clojure.main
                       -m puppetlabs.trapperkeeper.main
                       --config /etc/puppetlabs/console-services/conf.d
                       --bootstrap-config /etc/puppetlabs/console-services/bootstrap.cfg
                       --restart-file /opt/puppetlabs/server/data/console-services/restartcounter].join(" "),
               avg_cpu: 5, avg_mem: 50_000 },
      "6" => { cmd: %w[/opt/puppetlabs/server/bin/java
                       -Xmx704m
                       -Xms704m
                       -XX:+PrintGCDetails
                       -XX:+PrintGCDateStamps
                       -Xloggc:/var/log/puppetlabs/orchestration-services/orchestration-services_gc.log
                       -XX:+UseGCLogFileRotation
                       -XX:NumberOfGCLogFiles=16
                       -XX:GCLogFileSize=64m
                       -Djava.security.egd=/dev/urandom
                       -XX:OnOutOfMemoryError=kill -9 %p
                       -cp /opt/puppetlabs/server/apps/orchestration-services/orchestration-services-release.jar clojure.main
                       -m puppetlabs.trapperkeeper.main
                       --config /etc/puppetlabs/orchestration-services/conf.d
                       --bootstrap-config /etc/puppetlabs/orchestration-services/bootstrap.cfg
                       --restart-file /opt/puppetlabs/server/data/orchestration-services/restartcounter].join(" "),
               avg_cpu: 6, avg_mem: 60_000 },
      "7" => { cmd: %w[/opt/puppetlabs/server/bin/java
                       -Xms2048m
                       -Xmx2048m
                       -Djava.io.tmpdir=/opt/puppetlabs/server/apps/puppetserver/tmp
                       -XX:ReservedCodeCacheSize=512m
                       -XX:+PrintGCDetails
                       -XX:+PrintGCDateStamps
                       -Xloggc:/var/log/puppetlabs/puppetserver/puppetserver_gc.log
                       -XX:+UseGCLogFileRotation
                       -XX:NumberOfGCLogFiles=16
                       -XX:GCLogFileSize=64m
                       -Djava.security.egd=/dev/urandom
                       -XX:OnOutOfMemoryError=kill -9 %p
                       -cp /opt/puppetlabs/server/apps/puppetserver/puppet-server-release.jar:/opt/puppetlabs/server/apps/puppetserver/jruby-9k.jar:/opt/puppetlabs/server/data/puppetserver/jars/* clojure.main
                       -m puppetlabs.trapperkeeper.main
                       --config /etc/puppetlabs/puppetserver/conf.d
                       --bootstrap-config /etc/puppetlabs/puppetserver/bootstrap.cfg
                       --restart-file /opt/puppetlabs/server/data/puppetserver/restartcounter].join(" "),
                avg_cpu: 7, avg_mem: 70_000 }
    }
    # rubocop:enable Metrics/LineLength
  end
  let(:valid_process_hash) do
    {
      "process_puppetdb_avg_cpu"                       => 3,
      "process_puppetdb_avg_mem"                       => 30_000,
      "process_console_services_release_avg_cpu"       => 5,
      "process_console_services_release_avg_mem"       => 50_000,
      "process_orchestration_services_release_avg_cpu" => 6,
      "process_orchestration_services_release_avg_mem" => 60_000,
      "process_puppet_server_release_avg_cpu"          => 7,
      "process_puppet_server_release_avg_mem"          => 70_000
    }
  end
  let(:baseline_result) do
    {
      pe_build_number: "2018.1.4",
      test_scenario: "apples to apples",
      time_stamp: "2018-09-27 16:03:21 -0700",
      avg_cpu: 25,
      avg_mem: 200_000,
      avg_disk_write: 30_000,
      avg_response_time: 1000,
      process_puppetdb_avg_cpu: 7,
      process_puppetdb_avg_mem: 708_717,
      process_console_services_release_avg_cpu: 2,
      process_console_services_release_avg_mem: 696_791,
      process_orchestration_services_release_avg_cpu: 4,
      process_orchestration_services_release_avg_mem: 535_163,
      process_puppet_server_release_avg_cpu: 5,
      process_puppet_server_release_avg_mem: 3_744_520
    }
  end

  let(:atop_result) { double("Beaker::DSL::BeakerBenchmark::Helpers::PerformanceResult") }

  describe "#perf_setup" do # rubocop:disable Metrics/BlockLength
    gatling_scenario = "test_gatling_scenario"
    simulation_id = "test_simulation_id"
    gatling_assertions = "SUCCESSFUL_REQUESTS=123 " + "MAX_RESPONSE_TIME_AGENT=12345 " + "TOTAL_REQUEST_COUNT=23456 "
    test_timestamp = "34567"

    context "when called with the expected args" do
      let!(:master) { [] }

      before do
        allow(subject).to receive(:master).and_return(master)
      end

      it "starts atop monitoring and sets the timestamp instance variable" do
        allow(subject).to receive(:create_perf_archive_root)
        allow(subject).to receive(:capture_current_tune_settings)
        allow(subject).to receive(:execute_gatling_scenario)
        allow(subject).to receive(:generate_timestamp_file)

        expect(subject).to receive(:start_monitoring).and_return(test_timestamp)
        subject.perf_setup(gatling_scenario, simulation_id, gatling_assertions)

        expect(subject.instance_variable_get(:@atop_session_timestamp)).to eq(test_timestamp)
      end

      # TODO: separate test per case or combine?
      it "creates the perf archive root" do
        allow(subject).to receive(:start_monitoring)
        allow(subject).to receive(:capture_current_tune_settings)
        allow(subject).to receive(:execute_gatling_scenario)
        allow(subject).to receive(:generate_timestamp_file)

        expect(subject).to receive(:create_perf_archive_root)
        subject.perf_setup(gatling_scenario, simulation_id, gatling_assertions)
      end

      it "captures the current tune settings" do
        allow(subject).to receive(:start_monitoring)
        allow(subject).to receive(:create_perf_archive_root)
        allow(subject).to receive(:execute_gatling_scenario)
        allow(subject).to receive(:generate_timestamp_file)

        expect(subject).to receive(:capture_current_tune_settings)
        subject.perf_setup(gatling_scenario, simulation_id, gatling_assertions)
      end

      it "generates timestamps" do
        allow(subject).to receive(:start_monitoring)
        allow(subject).to receive(:capture_current_tune_settings)
        allow(subject).to receive(:create_perf_archive_root)
        allow(subject).to receive(:execute_gatling_scenario)

        expect(subject).to receive(:generate_timestamp_file).twice
        subject.perf_setup(gatling_scenario, simulation_id, gatling_assertions)
      end

      it "executes the gatling scenario" do
        allow(subject).to receive(:start_monitoring)
        allow(subject).to receive(:create_perf_archive_root)
        allow(subject).to receive(:capture_current_tune_settings)
        allow(subject).to receive(:generate_timestamp_file)

        expect(subject).to receive(:execute_gatling_scenario)
          .with(gatling_scenario, simulation_id, gatling_assertions)
        subject.perf_setup(gatling_scenario, simulation_id, gatling_assertions)
      end
    end
  end

  describe "#perf_result" do
    test_perf_result = "test result"

    context "when @perf_result has been set" do
      it "returns the value without updating it" do
        subject.instance_variable_set(:@perf_result, test_perf_result)

        expect(subject).not_to receive(:get_perf_result)
        expect(subject.perf_result).to eq(test_perf_result)

        expect(subject.instance_variable_get(:@perf_result)).to eq(test_perf_result)
      end
    end

    context "when @perf_result has not been set" do
      it "gets the perf result and sets the instance variable" do
        expect(subject).to receive(:get_perf_result).and_return(test_perf_result)
        expect(subject.perf_result).to eq(test_perf_result)
        expect(subject.instance_variable_get(:@perf_result)).to eq(test_perf_result)
      end
    end
  end

  # TODO
  describe "#perf_teardown" do
    context "when called" do
      it "" do
      end
    end
  end

  describe "#create_perf_archive_root" do
    context "when called" do
      before do
        stub_const("PerfRunHelper::PERF_RESULTS_DIR", TEST_DIR)
      end

      it "sets @gplt_timestamp" do
        allow(FileUtils).to receive(:mkdir_p)
        expect(Time).to receive(:now).and_return(TEST_TIME_NOW)
        expect(subject).to receive(:hosts).and_return(hosts)
        allow(subject).to receive(:get_most_relevant_role).and_return("master")

        subject.create_perf_archive_root
        expect(subject.instance_variable_get(:@gplt_timestamp)).to eq(TEST_TIMESTAMP)
      end

      it "sets @archive_root with the @gplt_timestamp" do
        subject.instance_variable_set("@gplt_timestamp", TEST_TIMESTAMP)

        allow(FileUtils).to receive(:mkdir_p)
        expect(Time).to receive(:now).and_return(TEST_TIME_NOW)
        expect(subject).to receive(:hosts).and_return(hosts)
        allow(subject).to receive(:get_most_relevant_role).and_return("master")

        subject.create_perf_archive_root
        expect(subject.instance_variable_get(:@archive_root)).to eq(TEST_ARCHIVE_ROOT)
      end

      it "creates the 'archive root' directory" do
        subject.instance_variable_set("@gplt_timestamp", TEST_TIMESTAMP)

        expect(Time).to receive(:now).and_return(TEST_TIME_NOW)
        expect(subject).to receive(:hosts).and_return(hosts)
        allow(subject).to receive(:get_most_relevant_role).and_return("master")
        expect(FileUtils).to receive(:mkdir_p).with(TEST_ARCHIVE_ROOT)
        allow(FileUtils).to receive(:mkdir_p)

        subject.create_perf_archive_root
      end

      it "creates the host specific directories" do
        subject.instance_variable_set("@gplt_timestamp", TEST_TIMESTAMP)

        expect(Time).to receive(:now).and_return(TEST_TIME_NOW)
        expect(subject).to receive(:hosts).and_return(hosts)
        allow(subject).to receive(:get_most_relevant_role).and_return("master")
        expect(FileUtils).to receive(:mkdir_p).with(TEST_ARCHIVE_ROOT)
        expect(FileUtils).to receive(:mkdir_p).with("#{TEST_ARCHIVE_ROOT}/hosts")
        hosts.each do |host|
          expected_path = "#{TEST_ARCHIVE_ROOT}/hosts/master/#{host.hostname}"
          expect(FileUtils).to receive(:mkdir_p).with(expected_path)
        end

        subject.create_perf_archive_root
      end
    end
  end

  describe "#get_most_relevant_role" do
    context "when called with a host that has one role" do
      context "that role is a primary role" do
        let!(:test_host) { { roles: ["master"] } }
        it "returns the primary role" do
          expect(subject.get_most_relevant_role(test_host)).to eq("master")
        end
      end

      context "that role is NOT a primary role" do
        let!(:test_host) { { roles: ["joker"] } }
        it "returns unknown" do
          expect(subject.get_most_relevant_role(test_host)).to eq("unknown")
        end
      end
    end

    context "when called with a host that has more than one role" do
      context "those roles have only one primary role" do
        let!(:test_host) { { roles: %w[master joker] } }
        it "returns the primary role" do
          expect(subject.get_most_relevant_role(test_host)).to eq("master")
        end
      end

      context "those roles have two primary roles" do
        let!(:test_host) { { roles: %w[master database] } }
        it "returns only one role" do
          expect(subject.get_most_relevant_role(test_host)).to eq("master")
        end
      end

      context "those roles have no primary roles" do
        let!(:test_host) { { roles: %w[joker stoker] } }
        it "returns unknown" do
          expect(subject.get_most_relevant_role(test_host)).to eq("unknown")
        end
      end
    end

    context "when called with a host that has the primary role of compile master" do
      let!(:test_host) { { roles: %w[compile_master] } }
      it "returns compiler" do
        expect(subject.get_most_relevant_role(test_host)).to eq("compiler")
      end
    end
  end

  describe "#capture_current_tune_settings" do
    context "when called" do
      let!(:master) { [] }
      let!(:result) { Class.new }

      before do
        subject.instance_variable_set("@archive_root", TEST_ARCHIVE_ROOT)
        allow(subject).to receive(:puts)
        allow(subject).to receive(:master).and_return(master)
      end

      it "captures the tune settings" do
        allow(File).to receive(:write)
        expect(subject).to receive(:run_script_on).exactly(hosts.count).times.and_return(result)
        expect(result).to receive(:output).exactly(hosts.count).times.and_return(TEST_JSON)
        expect(subject).to receive(:hosts).and_return(hosts)
        allow(subject).to receive(:get_most_relevant_role).and_return("foo")

        subject.capture_current_tune_settings
      end

      it "writes the settings to the @archive_root" do
        allow(subject).to receive(:run_script_on).and_return(result)
        allow(result).to receive(:output).and_return(TEST_JSON)
        expect(subject).to receive(:hosts).and_return(hosts)
        allow(subject).to receive(:get_most_relevant_role).and_return("master")
        hosts.each do |host|
          expected_path = "#{TEST_ARCHIVE_ROOT}/hosts/master/#{host.hostname}/\
current_tune_settings.json"
          expect(File).to receive(:write).with(expected_path, TEST_JSON)
        end

        subject.capture_current_tune_settings
      end
    end
  end

  describe "#generate_timestamp_file" do
    context "when called" do
      before do
        subject.instance_variable_set("@archive_root", TEST_ARCHIVE_ROOT)
      end

      it "writes the timestamp file to the @archive_root" do
        filename = "foo"
        expected_path = "#{TEST_ARCHIVE_ROOT}/#{filename}"

        expect(Time).to receive(:now).and_return(TEST_TIMESTAMP)
        expect(File).to receive(:write).with(expected_path, TEST_TIMESTAMP)

        subject.generate_timestamp_file(filename)
      end
    end
  end

  describe "#assert_later" do
    context "when true" do
      it "does not raise, or store exception" do
        expect(subject).to receive(:assertion_exceptions).and_return([])
        expect(subject).to \
          receive(:assert).with(true == true, "expression = true") # rubocop:disable Lint/UselessComparison
        subject.assert_later(true == true, "expression = true") # rubocop:disable Lint/UselessComparison
        expect(subject.assertion_exceptions.length).to eq(0)
      end
    end

    context "when false" do
      it "does not raise, but does store exception" do
        expect(subject).to receive(:assert).with(true == false, "expression = false")
                                           .and_raise(Minitest::Assertion, "expression = false")
        allow(subject).to receive(:assertion_exceptions).and_call_original
        subject.assert_later(true == false, "expression = false")
        expect(subject.assertion_exceptions.length).to eq(1)
      end
    end
  end

  describe "#assert_all" do
    let(:logger) { double }
    before { allow(subject).to receive(:logger).and_return(logger) }

    context "when assertion fails" do
      it "raises exception" do
        allow(subject).to receive(:assertion_exceptions).and_call_original

        expect(subject).to receive(:flunk).with("One or more assertions failed")
                                          .and_raise(Minitest::Assertion, "One or more assertions failed")
        expect(logger).to receive(:error).with(/expression = false/)

        subject.assertion_exceptions.push(Minitest::Assertion.new("expression = false"))
        expect { subject.assert_all }.to raise_error(Minitest::Assertion, "One or more assertions failed")
      end
    end

    context "when no assertions fail" do
      it "does not raise exception" do
        allow(subject).to receive(:assertion_exceptions).and_call_original
        allow(subject).to \
          receive(:assert).with(true == true, "expression = true") # rubocop:disable Lint/UselessComparison

        subject.assert_later(true == true, "expression = true") # rubocop:disable Lint/UselessComparison

        expect { subject.assert_all }.not_to raise_error
      end
    end

    context "when more than one assertion fails" do
      it "raises a single exception" do
        allow(subject).to receive(:assertion_exceptions).and_call_original

        expect(subject).to receive(:flunk).with("One or more assertions failed")
                                          .and_raise(Minitest::Assertion, "One or more assertions failed")
        subject.assertion_exceptions.push(Minitest::Assertion.new("expression = false 1"))
        subject.assertion_exceptions.push(Minitest::Assertion.new("expression = false 2"))
        expect(logger).to receive(:error).with(/expression = false 1/)
        expect(logger).to receive(:error).with(/expression = false 2/)

        expect { subject.assert_all }.to raise_error(Minitest::Assertion, "One or more assertions failed")
      end
    end
  end

  describe "#get_process_hash" do
    context "when it has everything needed" do
      it "succeeds" do
        process_hash = subject.send(:get_process_hash, perf_result_processes)
        expect(process_hash).to eql(valid_process_hash)
      end
    end
  end

  describe "#baseline_assert" do
    # rubocop:disable Metrics/LineLength
    let(:gatling_assertions) do
      [{ "expected_values" => [100.0],
         "message"         => "Global: percentage of successful requests is greater than or equal to 100.0",
         "actual_value"    => [100.0],
         "target"          => "percentage of successful requests" },
       {                           "expected_values" => [baseline_result[:avg_response_time]],
                                   "message"         => "PerfTestLarge: 99th percentile of response time is less than or equal to 20000.0",
                                   "actual_value"    => [baseline_result[:avg_response_time]],
                                   "target"          => "99th percentile of response time" },
       {                           "expected_values" => [28_800.0],
                                   "message"         => "Global: count of all requests is 28800.0",
                                   "actual_value"    => [28_800.0],
                                   "target"          => "count of all requests" }]
    end
    # rubocop:enable Metrics/LineLength
    let(:gatling_result) { PerfRunHelper::GatlingResult.new(gatling_assertions, 42) }

    let(:atop_result) do
      Beaker::DSL::BeakerBenchmark::Helpers::PerformanceResult.new(
        cpu: [],
        mem: [],
        disk_read: [],
        disk_write: [],
        action: "foo",
        duration: "99.99",
        processes: {},
        logger: nil,
        hostname: "foobar"
      )
    end

    before do
      allow(subject).to receive(:puts)
    end

    context "when assertion succeeds" do
      it "succeeds with no exceptions" do
        expect(subject).to receive(:get_baseline_result).and_return(baseline_result)
        expect(subject).to receive(:assert).with(any_args).and_return(nil)
        subject.send(:baseline_assert, atop_result, gatling_result)
      end
    end

    context "when assertions fail" do
      it "raises exception" do
        expect(subject).to receive(:get_baseline_result).and_return(baseline_result)
        expect(subject).to receive(:assert).with(any_args).and_raise(Minitest::Assertion)
        subject.send(:baseline_assert, atop_result, gatling_result)
      end
    end
  end

  describe "#copy_system_logs" do
    let(:host) { double.as_null_object }
    let(:archive_root) { "/tmp/test/archive" }
    let(:archive_dir) { "/var/log" }
    let(:archive_name) { "puppet_logdir.tgz" }
    let(:archive_path) { File.join(archive_dir, archive_name) }

    context "when archiving succeeds" do
      before { subject.instance_variable_set(:@archive_root, archive_root) }
      before { allow(subject).to receive(:archive_system_logs).with(host).and_return(archive_path) }
      before { allow(subject).to receive(:scp_from) }
      before { allow(FileUtils).to receive(:mkdir_p) }

      it "calls scp_from to copy archive path to archive root" do
        expected_dest = File.join(archive_root, host)
        expect(subject).to receive(:scp_from).with(host, archive_path, expected_dest)
        subject.copy_system_logs(host)
      end

      it "calls mkdir_p to create the local destination path" do
        expected_dest = File.join(archive_root, host)
        expect(FileUtils).to receive(:mkdir_p).with(expected_dest)
        subject.copy_system_logs(host)
      end
    end

    context "when archiving fails" do
      before { allow(subject).to receive(:archive_system_logs).with(host).and_return(nil) }

      it "does not call scp_from" do
        expect(subject).not_to receive(:scp_from)
        subject.copy_system_logs(host)
      end

      it "does not call mkdir_p" do
        expect(FileUtils).not_to receive(:mkdir_p)
        subject.copy_system_logs(host)
      end
    end
  end

  describe "#archive_system_logs" do
    let(:host) { double.as_null_object }
    let(:logger) { double.as_null_object }
    let(:puppet_logdir) { "/var/log/puppetlabs/puppet" }
    let(:archive_dir) { "/var/log" }
    let(:archive_name) { "puppet_logdir.tgz" }
    let(:archive_path) { File.join(archive_dir, archive_name) }

    let(:result) { Beaker::Result.new(host, "foo") }
    let(:cmd1) { "rm -f #{archive_path}" }
    let(:cmd2) { "cd #{archive_dir} && tar -czf #{archive_name} puppetlabs" }

    before(:each) do
      allow(subject).to receive(:logger).and_return(logger)
      allow(subject).to receive(:puppet).and_return(puppet_logdir)

      expect(subject).to receive(:on).with(host, puppet_logdir).ordered.and_return(result)
      expect(subject).to receive(:on).with(host, cmd1, accept_all_exit_codes: true).ordered.and_return(result)
      expect(subject).to receive(:on).with(host, cmd2, accept_all_exit_codes: true).ordered.and_return(result)
    end

    context "when archiving succeeds" do
      before :each do
        result.stdout = puppet_logdir
        result.exit_code = 0
      end
      it "returns archive path" do
        expect(subject.archive_system_logs(host)).to eq(archive_path)
      end
      it "runs tar on the host" do
        subject.archive_system_logs(host)
      end
    end
    context "when archiving fails" do
      before :each do
        result.stdout = puppet_logdir
        result.exit_code = 1
      end
      it "returns nil" do
        expect(subject.archive_system_logs(host)).to eq(nil)
      end
    end
  end
  describe "#validate_results_to_baseline" do
    let(:gatling_assertion_content) do # {{{
      <<~ASSERTIONS
        {
          "simulation": "com.puppetlabs.gatling.runner.ConfigDrivenSimulation",
          "simulationId": "PerfTestLarge",
          "start": 1571758226846,
          "description": "'role::by_size_large' role from perf control repo, 600 agents, 8 iterations",
          "scenarios": ["PerfTestLarge"],
          "assertions": [
        {
          "path": "Global",
          "target": "percentage of successful requests",
          "actualValue": [100.0]
        },
        {
          "path": "PerfTestLarge",
          "target": "99th percentile of response time",
          "actualValue": [3258.0]
        },
        {
          "path": "Global",
          "target": "count of all requests",
          "actualValue": [28800.0]
        }
          ]
        }
      ASSERTIONS
    end
    # }}}
    context "when validation passes" do
      # rubocop:disable Metrics/LineLength
      let(:atop_file_content) do
        "Action,Duration,Avg CPU,Avg MEM,Avg DSK read,Avg DSK Write
        ApplesToApples.json,14416.49,#{baseline_result[:avg_cpu]},#{baseline_result[:avg_mem]},43,#{baseline_result[:avg_disk_write]}

        Process pid,command,Avg CPU,Avg MEM,Avg DSK read,Avg DSK Write
        17610,'/path/puppetdb.jar',#{baseline_result[:process_puppetdb_avg_cpu]},#{baseline_result[:process_puppetdb_avg_mem]},0,1169
        18194,'/path/orchestration-services-release.jar',#{baseline_result[:process_orchestration_services_release_avg_cpu]},#{baseline_result[:process_orchestration_services_release_avg_mem]},0,15
        18805,'/path/console-services-release.jar',#{baseline_result[:process_console_services_release_avg_cpu]},#{baseline_result[:process_console_services_release_avg_mem]},0,26
        23970,'/path/puppet-server-release.jar',#{baseline_result[:process_puppet_server_release_avg_cpu]},#{baseline_result[:process_puppet_server_release_avg_mem]},0,309"
      end
      # rubocop:enable Metrics/LineLength
      # }}}
      let(:gatling_stats_content) do # {{{
        <<~STATS
          {
              "name": "Global Information",
              "meanResponseTime": {
                  "total": #{baseline_result[:avg_response_time]},
                  "ok": #{baseline_result[:avg_response_time]},
                  "ko": 0
              }
          }
        STATS
      end
      # }}}
      it "returns true" do
        allow(subject).to receive(:find_atop_log_from_dir).with("foo", "applestoapples").and_return("atop_file")
        allow(subject).to receive(:find_gatling_assertions_from_dir).with("foo").and_return("assertion_file")
        allow(subject).to receive(:find_gatling_stats_from_dir).with("foo").and_return("stats_file")
        allow(subject).to receive(:read_file).with("atop_file").and_return(atop_file_content)
        allow(subject).to receive(:read_file).with("assertion_file").and_return(gatling_assertion_content)
        allow(subject).to receive(:read_file).with("stats_file").and_return(gatling_stats_content)
        allow(subject).to receive(:get_baseline_result).with("bar").and_return(baseline_result)
        expect(subject.validate_results_to_baseline("foo", "bar", "apples to apples")).to eq(true)
      end
    end
    context "when validation fails" do
      bad_cpu = bad_mem = bad_disk_write = bad_time = "999999"
      let(:atop_file_content) do # {{{
        "Action,Duration,Avg CPU,Avg MEM,Avg DSK read,Avg DSK Write
        ApplesToApples.json,14416.49,#{bad_cpu},#{bad_mem},43,#{bad_disk_write}

        Process pid,command,Avg CPU,Avg MEM,Avg DSK read,Avg DSK Write
        17610,'/path/puppetdb.jar',#{bad_cpu},#{bad_mem},0,1169
        18194,'/path/orchestration-services-release.jar',#{bad_cpu},#{bad_mem},0,15
        18805,'/path/console-services-release.jar',#{bad_cpu},#{bad_mem},0,26
        23970,'/path/puppet-server-release.jar',#{bad_cpu},#{bad_mem},0,309"
      end
      # }}}
      let(:gatling_stats_content) do # {{{
        <<~STATS
          {
              "name": "Global Information",
              "meanResponseTime": {
                  "total": #{bad_time},
                  "ok": #{bad_time},
                  "ko": 0
              }
          }
        STATS
      end
      # }}}
      it "returns false" do
        allow(subject).to receive(:find_atop_log_from_dir).with("foo", "applestoapples").and_return("atop_file")
        allow(subject).to receive(:find_gatling_assertions_from_dir).with("foo").and_return("assertion_file")
        allow(subject).to receive(:find_gatling_stats_from_dir).with("foo").and_return("stats_file")
        allow(subject).to receive(:read_file).with("atop_file").and_return(atop_file_content)
        allow(subject).to receive(:read_file).with("assertion_file").and_return(gatling_assertion_content)
        allow(subject).to receive(:read_file).with("stats_file").and_return(gatling_stats_content)
        allow(subject).to receive(:get_baseline_result).with("bar").and_return(baseline_result)
        expect(subject.validate_results_to_baseline("foo", "bar", "apples to apples")).to eq(false)
      end
    end
  end
  describe "#validate_baseline_delta" do
    context "when all deltas are < MAX_BASELINE_VARIANCE" do
      it "returns true" do
        expect(subject.validate_baseline_data("pass_thing1" => [1.00, 0.98],
                                              "pass_thing2" => [100, 102])).to eq(true)
      end
    end
    context "when any delta is > MAX_BASELINE_VARIANCE" do
      it "returns false" do
        expect(subject.validate_baseline_data("fail_thing"  => [1, 2],
                                              "pass_thing2" => [100, 102])).to eq(false)
      end
    end
    context "when MAX_BASELINE_VARIANCE < 'orchestration_service memory delta' > MAX_BASELINE_VARIANCE_ORCH_REL_MEM" do
      it "returns true" do
        expect(
          subject.validate_baseline_data(
            "pass_thing1"                                    => [1.00, 0.98],
            "process_orchestration_services_release_avg_mem" => [100, 112]
          )
        ).to eq(true)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
