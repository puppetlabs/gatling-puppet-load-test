# frozen_string_literal: true

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

describe PerfRunHelperClass do # rubocop:disable Metrics/BlockLength
  let(:perf_result_processes) do # rubocop:disable Metrics/BlockLength
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
      "pe_build_number"                                => "2018.1.4",
      "test_scenario"                                  => "apples to apples",
      "time_stamp"                                     => "2018-09-27 16:03:21 -0700",
      "avg_cpu"                                        => 25,
      "avg_mem"                                        => 200_000,
      "avg_disk_write"                                 => 30_000,
      "avg_response_time"                              => 1000,
      "process_puppetdb_avg_cpu"                       => 7,
      "process_puppetdb_avg_mem"                       => 708_717,
      "process_console_services_release_avg_cpu"       => 2,
      "process_console_services_release_avg_mem"       => 696_791,
      "process_orchestration_services_release_avg_cpu" => 4,
      "process_orchestration_services_release_avg_mem" => 535_163,
      "process_puppet_server_release_avg_cpu"          => 5,
      "process_puppet_server_release_avg_mem"          => 3_744_520
    }
  end

  let(:gatling_result) { double("GatlingResult") }
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

        subject.create_perf_archive_root
        expect(subject.instance_variable_get(:@gplt_timestamp)).to eq(TEST_TIMESTAMP)
      end

      it "sets @archive_root with the @gplt_timestamp" do
        subject.instance_variable_set("@gplt_timestamp", TEST_TIMESTAMP)

        allow(FileUtils).to receive(:mkdir_p)
        expect(Time).to receive(:now).and_return(TEST_TIME_NOW)

        subject.create_perf_archive_root
        expect(subject.instance_variable_get(:@archive_root)).to eq(TEST_ARCHIVE_ROOT)
      end

      it "creates the 'archive root' directory" do
        subject.instance_variable_set("@gplt_timestamp", TEST_TIMESTAMP)

        expect(Time).to receive(:now).and_return(TEST_TIME_NOW)
        expect(FileUtils).to receive(:mkdir_p).with(TEST_ARCHIVE_ROOT)

        subject.create_perf_archive_root
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

        expect(subject).to receive(:run_script_on).and_return(result)
        expect(result).to receive(:output).and_return(TEST_JSON)

        subject.capture_current_tune_settings
      end

      it "writes the settings to the @archive_root" do
        expected_path = "#{TEST_ARCHIVE_ROOT}/current_tune_settings.json"

        allow(subject).to receive(:run_script_on).and_return(result)
        allow(result).to receive(:output).and_return(TEST_JSON)

        expect(File).to receive(:write).with(expected_path, TEST_JSON)

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

  describe ".assert_later" do
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

  describe ".assert_all" do
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

  describe ".get_process_hash" do
    context "when it has everything needed" do
      it "succeeds" do
        process_hash = subject.send(:get_process_hash, perf_result_processes)
        expect(process_hash).to eql(valid_process_hash)
      end
    end
  end

  describe ".baseline_assert" do
    before do
      allow(subject).to receive(:puts)
    end

    context "when assertion succeeds" do
      it "succeeds with no exceptions" do
        expect(subject).to receive(:get_process_hash).with(any_args).and_return(valid_process_hash)
        expect(subject).to receive(:get_baseline_result).and_return(baseline_result)
        allow(atop_result).to receive(:processes)
        allow(gatling_result).to receive(:avg_response_time).and_return(baseline_result[:avg_response_time])
        baseline_result.keys.each do |key|
          allow(atop_result).to receive(key.to_sym).and_return(baseline_result[key])
        end
        # TODO: change back when per process cpu asserts are turned back on
        # changed to 8 while per process cpu asserts are disabled.
        # expect(subject).to receive(:assert).with(any_args).exactly(12).times.and_return(nil)
        expect(subject).to receive(:assert).with(any_args).exactly(8).times.and_return(nil)
        subject.send(:baseline_assert, atop_result, gatling_result)
      end
    end

    context "when assertions fail" do
      it "raises exception" do
        expect(subject).to receive(:get_process_hash).with(any_args).and_return(valid_process_hash)
        expect(subject).to receive(:get_baseline_result).and_return(baseline_result)
        allow(atop_result).to receive(:processes)
        allow(gatling_result).to receive(:avg_response_time).and_return(baseline_result[:avg_response_time])
        baseline_result.keys.each do |key|
          allow(atop_result).to receive(key.to_sym).and_return(baseline_result[key])
        end
        # TODO: change back when per process cpu asserts are turned back on
        # changed to 8 while per process cpu asserts are disabled.
        # expect(subject).to receive(:assert).with(any_args).exactly(12).times.and_raise(Minitest::Assertion)
        # subject.send(:baseline_assert, atop_result, gatling_result)
        # expect(subject.assertion_exceptions.count()).to eql(12)
        expect(subject).to receive(:assert).with(any_args).exactly(8).times.and_raise(Minitest::Assertion)
        subject.send(:baseline_assert, atop_result, gatling_result)
        expect(subject.assertion_exceptions.count).to eql(8)
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
        expect(FileUtils).to receive(:mkdir_p)
        subject.copy_system_logs(host)
      end
    end
    context "when archiving fails" do
      before { allow(subject).to receive(:archive_system_logs).with(host).and_return(nil) }
      it "scp_from is not called" do
        expect(subject).not_to receive(:scp_from)
        subject.copy_system_logs(host)
      end
      it "mkdir_p is not called" do
        expect(FileUtils).not_to receive(:mkdir_p)
        subject.copy_system_logs(host)
      end
    end
  end
  describe "#archive_system_logs" do
    let(:host) { double.as_null_object }
    let(:puppet_logdir) { "/var/log/puppetlabs/puppet" }
    let(:archive_dir) { "/var/log" }
    let(:archive_name) { "puppet_logdir.tgz" }
    let(:archive_path) { File.join(archive_dir, archive_name) }

    context "when archiving succeeds" do
      it "returns archive path" do
        expect(subject).to receive(:archive_system_logs).with(host).and_return(archive_path)
        subject.archive_system_logs(host)
      end
      it "runs tar on the host" do
        result = Beaker::Result.new(host, "foo")
        result.stdout = puppet_logdir
        cmd1 = "rm -f #{archive_path}"
        cmd2 = "cd #{archive_dir} && tar -czf #{archive_name} puppetlabs"
        allow(subject).to receive(:puppet).and_return(puppet_logdir)
        expect(subject).to receive(:on).with(host, puppet_logdir).ordered.and_return(result)
        expect(subject).to receive(:on).with(host, cmd1, accept_all_exit_codes: true).ordered
        expect(subject).to receive(:on).with(host, cmd2, accept_all_exit_codes: true).ordered
        subject.archive_system_logs(host)
      end
    end
    context "when archiving fails" do
      it "returns nil" do
        expect(subject).to receive(:archive_system_logs).with(host).and_return(nil)
        subject.archive_system_logs(host)
      end
    end
  end
end
