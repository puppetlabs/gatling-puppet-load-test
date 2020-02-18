# frozen_string_literal: false

# rubocop:disable Metrics/BlockLength
require "spec_helper"
describe Metrics::ImportMetricsFiles do
  results_dir = "spec/fixtures/metrics/large"
  perf_results_dir = "#{results_dir}/perf/PERF_12345"
  scale_results_dir = "#{results_dir}/scale/PERF_SCALE_12345"
  non_results_dir = "#{results_dir}/not-a-results-dir"
  pmc_dir = "#{perf_results_dir}/puppet-metrics-collector"
  prefix = "slv-123"
  id = "12345"
  json2timeseriesdb_path = "/zzz/json2timeseriesdb.rb"

  before :all do
    IMF_obj = Metrics::ImportMetricsFiles.new(perf_results_dir, prefix, json2timeseriesdb_path)
  end

  before do
    allow(IMF_obj).to receive(:puts)
  end

  describe "#initialize" do
    it "converts the passed in parameters into attributes" do
      temp_imf = Metrics::ImportMetricsFiles.new(perf_results_dir, prefix, json2timeseriesdb_path)
      expect(temp_imf.instance_variable_get("@results_dir")).to eq(perf_results_dir)
      expect(temp_imf.instance_variable_get("@prefix")).to eq(prefix)
      expect(temp_imf.instance_variable_get("@json2timeseriesdb_path")).to eq(json2timeseriesdb_path)
      # expect(temp_imf.instance_variable_get("@id")).to eq(perf_results_dir.split("_").last)
    end

    context "when the specified results_dir is a GPLT perf results dir" do
      it "uses the last segment of the directory name as the ID" do
        temp_imf = Metrics::ImportMetricsFiles.new(perf_results_dir, prefix, json2timeseriesdb_path)
        expect(temp_imf.instance_variable_get("@id")).to eq(perf_results_dir.split("_").last)
      end
    end

    context "when the specified results_dir is a GPLT scale results dir" do
      it "uses the last segment of the directory name as the ID" do
        temp_imf = Metrics::ImportMetricsFiles.new(scale_results_dir, prefix, json2timeseriesdb_path)
        expect(temp_imf.instance_variable_get("@id")).to eq(scale_results_dir.split("_").last)
      end
    end

    context "when the specified results_dir is not a valid GPLT results dir" do
      it "sets the ID to nil" do
        temp_imf = Metrics::ImportMetricsFiles.new(non_results_dir, prefix, json2timeseriesdb_path)
        expect(temp_imf.instance_variable_get("@id")).to eq(nil)
      end
    end
  end

  describe "#valid_results_dir?" do
    context "when the specified directory is a GPLT perf directory" do
      it "returns true" do
        expect(IMF_obj.valid_results_dir?(perf_results_dir)).to eq(true)
      end
    end

    context "when the specified directory is a GPLT scale directory" do
      it "returns true" do
        expect(IMF_obj.valid_results_dir?(scale_results_dir)).to eq(true)
      end
    end

    context "when the specified directory is a not a GPLT results directory" do
      it "returns false" do
        expect(IMF_obj.valid_results_dir?(non_results_dir)).to eq(false)
      end
    end
  end

  describe "#import_metrics_files" do
    context "when the puppet-metrics-collector directory is not found" do
      it "raises an error" do
        expect(File).to receive(:directory?).with(pmc_dir).and_return(false)
        expect { IMF_obj.import_metrics_files }
          .to raise_error(RuntimeError)
      end
    end

    context "when the puppet-metrics-collector directory is found" do
      it "calls import_metrics_files_for_service_dir for each service directory" do
        expected_services = %w[orchestrator puppetdb puppetserver]
        expected_services.each do |service|
          path = "#{pmc_dir}/#{service}"
          expect(IMF_obj).to receive(:import_metrics_files_for_service_dir).with(path)
        end
        IMF_obj.import_metrics_files
      end
    end
  end

  describe "#output_settings" do
    it "outputs the settings" do
      settings = %w[results_dir prefix json2timeseriesdb_path id]
      settings.each do |setting|
        expect(IMF_obj).to receive(:puts).with(/#{Regexp.escape(setting)}/)
      end
      IMF_obj.output_settings
    end
  end

  describe "#import_metrics_files_for_service_dir" do
    it "calls import_metrics_files_for_host_dir for each host directory in the service directory" do
      service_dir = "#{pmc_dir}/puppetdb"
      expected_host_dirs = %w[1.1.1.1 1.1.1.2 1.1.1.3]
      expected_host_dirs.each do |host_dir|
        path = "#{service_dir}/#{host_dir}"
        expect(IMF_obj).to receive(:import_metrics_files_for_host_dir).with(path)
      end
      IMF_obj.import_metrics_files_for_service_dir(service_dir)
    end
  end

  describe "#import_metrics_files_for_host_dir" do
    it "calls the json2timeseriesdb script with the expected server tag" do
      host_dir = "#{pmc_dir}/puppetdb/1.1.1.1"
      hostname = File.basename(host_dir)
      expected_tag = "#{prefix}_#{id}_#{hostname}"
      expected_pattern = "'#{host_dir}/*.json'"
      expected_cmd = "#{json2timeseriesdb_path} --pattern #{expected_pattern}" \
        " --convert-to influxdb --netcat localhost --influx-db puppet_metrics --server-tag #{expected_tag}"

      expect(IMF_obj).to receive(:`).with(expected_cmd)
      IMF_obj.import_metrics_files_for_host_dir(host_dir)
    end

    context "when the command returns a non-zero exit code" do
      it "raises an error with the output" do
        expected_output = "ERROR"
        expected_status = 1
        host_dir = "#{pmc_dir}/puppetdb/1.1.1.1"

        expect(IMF_obj).to receive(:`).and_return(expected_output)

        `(exit #{expected_status})`
        expect($?).to receive(:success?).and_return(false) # rubocop:disable Style/SpecialGlobalVars

        expect { IMF_obj.import_metrics_files_for_host_dir(host_dir) }
          .to raise_error(RuntimeError, /#{expected_output}/)
      end
    end
  end

  describe "#build_server_tag" do
    test_hostname = "7.7.7.7"
    before do
      IMF_obj.instance_variable_set(:@hostname, test_hostname)
    end

    context "when the ID is not nil" do
      it "returns a server tag that includes the ID" do
        expected_tag = "#{prefix}_#{id}_#{test_hostname}"
        expect(IMF_obj.build_server_tag).to eq(expected_tag)
      end
    end

    context "when the ID is nil" do
      it "returns a server tag without an ID" do
        IMF_obj.instance_variable_set(:@id, nil)
        expected_tag = "#{prefix}_#{test_hostname}"
        expect(IMF_obj.build_server_tag).to eq(expected_tag)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
