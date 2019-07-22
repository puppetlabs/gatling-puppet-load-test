# frozen_string_literal: true

require "spec_helper"
require "minitest/assertions"

class PerfRunHelperClass
  include PerfRunHelper
  include Minitest::Assertions
end

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
end
