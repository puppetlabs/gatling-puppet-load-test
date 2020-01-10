# frozen_string_literal: false

# rubocop:disable Metrics/BlockLength
require "spec_helper"
describe Metrics::ImportMetricsFiles do
  results_dir = "spec/fixtures/metrics/large/perf/PERF_12345"
  pmc_dir = "#{results_dir}/puppet-metrics-collector"
  prefix = "slv-123"
  id = "12345"
  json2graphite_path = "/zzz/json2graphite.rb"

  before :all do
    IMF_obj = Metrics::ImportMetricsFiles.new(results_dir, prefix, json2graphite_path)
  end

  before do
    allow(IMF_obj).to receive(:puts)
  end

  describe "#initialize" do
    it "checks that the passed in parameters get converted into attributes" do
      temp_imf = Metrics::ImportMetricsFiles.new(results_dir, prefix, json2graphite_path)
      expect(temp_imf.instance_variable_get("@results_dir")).to eq(results_dir)
      expect(temp_imf.instance_variable_get("@prefix")).to eq(prefix)
      expect(temp_imf.instance_variable_get("@json2graphite_path")).to eq(json2graphite_path)
      expect(temp_imf.instance_variable_get("@id")).to eq(results_dir.split("_").last)
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
      settings = %w[results_dir prefix json2graphite_path id]
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
    it "calls the json2graphite script with the expected server tag" do
      host_dir = "#{pmc_dir}/puppetdb/1.1.1.1"
      hostname = "1.1.1.1"
      expected_tag = "#{prefix}_#{id}_#{hostname}"
      expected_pattern = "'#{host_dir}/*.json'"
      expected_cmd = "ruby #{json2graphite_path} --pattern #{expected_pattern}" \
        " --convert-to influxdb --netcat localhost --influx-db puppet_metrics --server-tag #{expected_tag}"

      expect(IMF_obj).to receive(:`).with(expected_cmd)
      IMF_obj.import_metrics_files_for_host_dir(host_dir)
    end
  end
end
# rubocop:enable Metrics/BlockLength
