# frozen_string_literal: false

require "spec_helper"

# rubocop:disable Metrics/BlockLength
describe Metrics::CollectMetricsFiles do
  start_epoch = 1_564_948_800 # Sunday, August 4, 2019 8:00:00 PM
  end_epoch = 1_565_380_800 # Friday, August 9, 2019 8:00:00 PM
  metrics_dir = "spec/fixtures/puppet-metrics-collector"
  output_dir = "/myoutput/dirname"
  tar_file_name = "tarry.tar.gz"
  poll_interval = 300 # 5minutes
  archive_interval = 86_400 # 24 hours
  verbose = false
  tmp_dir_name = "/mytemp/dirname"
  staging_dir = "#{tmp_dir_name}/puppet_metrics_collector"

  let(:puppet_metrics_collector_fixture) { "spec/fixtures/puppet-metrics-collector" }
  let(:real_tarfile) { "#{puppet_metrics_collector_fixture}/puppetdb/puppetdb-2019.07.09.02.45.01.tar.gz" }

  # puppetdb-2019.07.17.02.45.01.tar.gz   20190718T092001Z.json
  # 30 hours before start - 1564840800 - Saturday, August 3, 2019 2:00:00 PM
  # 5 hours before start - 1564930800 - Sunday, August 4, 2019 3:00:00 PM
  # middle epoch - 1565164800 - Wednesday, August 7, 2019 8:00:00 AM
  # 5 hours after end - 1565398800 - Saturday, August 10, 2019 1:00:00 AM
  # 30 hours after end - 1565488800 - Sunday, August 11, 2019 2:00:00 AM

  let(:json_name_30h_before_window) { "/foo/bar/20190803T020000Z.json" }
  let(:json_name_5h_before_window)  { "/foo/bar/20190804T030000Z.json" }
  let(:json_name_middle_of_window)  { "/foo/bar/20190807T080000Z.json" }
  let(:json_name_5h_after_window)   { "/foo/bar/20190810T010000Z.json" }
  let(:json_name_30h_after_window)  { "/foo/bar/20190811T020000Z.json" }

  let(:tar_name_30h_before_window) { "/foo/bar/puppetdb/puppetdb-2019.08.03.02.00.00.tar.gz" }
  let(:tar_name_5h_before_window)  { "/foo/bar/puppetdb/puppetdb-2019.08.04.03.00.00.tar.gz" }
  let(:tar_name_middle_of_window)  { "/foo/bar/puppetdb/puppetdb-2019.08.07.08.00.00.tar.gz" }
  let(:tar_name_5h_after_window)   { "/foo/bar/puppetdb/puppetdb-2019.08.10.01.00.00.tar.gz" }
  let(:tar_name_30h_after_window)  { "/foo/bar/puppetdb/puppetdb-2019.08.11.02.00.00.tar.gz" }

  let(:zipreader) { Class.new }

  before :all do
    CMF_obj = Metrics::CollectMetricsFiles.new(start_epoch, end_epoch, metrics_dir, output_dir,
                                               tar_file_name, poll_interval, archive_interval, verbose)
    CMF_obj.instance_variable_set("@parent_staging_dir", tmp_dir_name)
    CMF_obj.instance_variable_set("@staging_dir", staging_dir)
  end

  describe "#initialize" do
    it "checks that the passed in parameters get converted into attributes" do
      temp_collect_metrics_files = Metrics::CollectMetricsFiles.new(start_epoch, end_epoch, metrics_dir,
                                                                    output_dir, tar_file_name,
                                                                    poll_interval, archive_interval, verbose)
      expect(temp_collect_metrics_files.instance_variable_get("@start_epoch")).to eq(start_epoch)
      expect(temp_collect_metrics_files.instance_variable_get("@end_epoch")).to eq(end_epoch)
      expect(temp_collect_metrics_files.instance_variable_get("@metrics_dir")).to eq(metrics_dir)
      expect(temp_collect_metrics_files.instance_variable_get("@output_dir")).to eq(output_dir)
      expect(temp_collect_metrics_files.instance_variable_get("@tar_file_name")).to eq(tar_file_name)
      expect(temp_collect_metrics_files.instance_variable_get("@poll_interval")).to eq(poll_interval)
      expect(temp_collect_metrics_files.instance_variable_get("@archive_interval")).to eq(archive_interval)
      expect(temp_collect_metrics_files.instance_variable_get("@verbose")).to eq(verbose)
    end
  end

  describe "#inspect_metrics_dir_for_service_dirs" do
    it "Correctly filters out subdirs known to have no data and continues on with the rest" do
      expect(CMF_obj).not_to receive(:inspect_service_dir_for_metrics_files)
        .with("#{puppet_metrics_collector_fixture}/bin", "bin")
      expect(CMF_obj).not_to receive(:inspect_service_dir_for_metrics_files)
        .with("#{puppet_metrics_collector_fixture}/scripts", "scripts")
      expect(CMF_obj).to receive(:inspect_service_dir_for_metrics_files)
        .with("#{puppet_metrics_collector_fixture}/puppetdb", "puppetdb")
      expect(CMF_obj).to receive(:inspect_service_dir_for_metrics_files)
        .with("#{puppet_metrics_collector_fixture}/puppetserver", "puppetserver")
      expect(CMF_obj).to receive(:inspect_service_dir_for_metrics_files)
        .with("#{puppet_metrics_collector_fixture}/orchestrator", "orchestrator")
      CMF_obj.inspect_metrics_dir_for_service_dirs
    end
  end

  describe "#inspect_service_dir_for_metrics_files" do
    it "Calls methods to look at the tar and json files in the fixture" do
      expect(CMF_obj).to receive(:consider_tarfile_contents_for_inclusion)
        .with("#{puppet_metrics_collector_fixture}/puppetdb/puppetdb-2019.07.09.02.45.01.tar.gz", "puppetdb")
      expect(CMF_obj).to receive(:consider_tarfile_contents_for_inclusion)
        .with("#{puppet_metrics_collector_fixture}/puppetdb/puppetdb-2019.07.17.02.45.01.tar.gz", "puppetdb")
      expect(CMF_obj).to receive(:consider_json_for_inclusion)
        .with("#{puppet_metrics_collector_fixture}/puppetdb/ip-10-227-1-138.amz-dev.puppet.net/20190718T092001Z.json")
      expect(CMF_obj).to receive(:consider_json_for_inclusion)
        .with("#{puppet_metrics_collector_fixture}/puppetdb/ip-10-227-1-138.amz-dev.puppet.net/20190718T173001Z.json")
      CMF_obj.inspect_service_dir_for_metrics_files("#{puppet_metrics_collector_fixture}/puppetdb",
                                                    "puppetdb")
    end
  end

  describe "#json_file_from_target_window?" do
    it "returns false for a json that dosn't use the naming convention" do
      expect(CMF_obj.json_file_from_target_window?("/foo/bar/my.json")).to eq(false)
    end
    it "returns false for a json from 30h before the window" do
      expect(CMF_obj.json_file_from_target_window?(json_name_30h_before_window)).to eq(false)
    end
    it "returns false for a json from 5h before the window" do
      expect(CMF_obj.json_file_from_target_window?(json_name_5h_before_window)).to eq(false)
    end
    it "returns true for a json from inside the window" do
      expect(CMF_obj.json_file_from_target_window?(json_name_middle_of_window)).to eq(true)
    end
    it "returns false for a json from 5h after the window" do
      expect(CMF_obj.json_file_from_target_window?(json_name_5h_after_window)).to eq(false)
    end
    it "returns false for a json from 30h after the window" do
      expect(CMF_obj.json_file_from_target_window?(json_name_30h_after_window)).to eq(false)
    end
  end

  describe "#consider_json_for_inclusion?" do
    context "when json_file_from_target_window? returns true" do
      it "calls stage_json" do
        expect(CMF_obj).to receive(:json_file_from_target_window?).with(json_name_middle_of_window).and_return(true)
        expect(CMF_obj).to receive(:stage_json).with(json_name_middle_of_window)
        CMF_obj.consider_json_for_inclusion(json_name_middle_of_window)
      end
    end
    context "when json_file_from_target_window? returns false" do
      it "does not call stage_json" do
        expect(CMF_obj).to receive(:json_file_from_target_window?).and_return(false)
        expect(CMF_obj).not_to receive(:stage_json)
        CMF_obj.consider_json_for_inclusion(json_name_30h_after_window)
      end
    end
  end

  describe "#stage_json" do
    before do
      @filename = File.basename(json_name_middle_of_window)
      @destination_dir = staging_dir + "/" + File.dirname(json_name_middle_of_window)
    end
    context "when directory? returns false" do
      it "copies files and calls mkdir for the destination dir" do
        expect(FileUtils).to receive(:mkdir_p).with(@destination_dir).at_least(1).times
        expect(File).to receive(:directory?).with(@destination_dir).and_return(false)
        expect(FileUtils).to receive(:cp).with(json_name_middle_of_window, "#{@destination_dir}/#{@filename}").once
        CMF_obj.stage_json(json_name_middle_of_window)
      end
    end
    context "when directory? returns true" do
      it "copies files and does not calls mkdir for the destination dir" do
        expect(FileUtils).not_to receive(:mkdir_p)
        expect(File).to receive(:directory?).with(@destination_dir).and_return(true)
        expect(FileUtils).to receive(:cp).with(json_name_middle_of_window,
                                               "#{@destination_dir}/#{@filename}").and_return(true)
        CMF_obj.stage_json(json_name_middle_of_window)
      end
    end
  end

  describe "#consider_tarfile_contents_for_inclusion" do
    before do
      @filename = File.basename(real_tarfile)
      @service = "puppetdb"
    end
    context "when tarfile_from_target_window? returns false" do
      it "not to stage any jsons from the tarfile" do
        expect(CMF_obj).to receive(:tarfile_from_target_window?).with(@filename, @service).and_return(false)
        expect(CMF_obj).not_to receive(:stage_jsons_from_tarfile)
        CMF_obj.consider_tarfile_contents_for_inclusion(real_tarfile, @service)
      end
    end
    context "when tarfile_from_target_window? returns true" do
      context "when json_file_from_target_window? always returns false" do
        it "not to stage any jsons from the tarfile" do
          expect(CMF_obj).to receive(:tarfile_from_target_window?).with(@filename, @service).and_return(true)
          expect(CMF_obj).to receive(:json_file_from_target_window?).and_return(false).at_least(:once)
          expect(CMF_obj).to receive(:puts)
          expect(CMF_obj).not_to receive(:stage_jsons_from_tarfile)
          CMF_obj.consider_tarfile_contents_for_inclusion(real_tarfile, @service)
        end
      end
      context "when json_file_from_target_window? always returns true" do
        it "to stage jsons from the tarfile" do
          expect(CMF_obj).to receive(:tarfile_from_target_window?).with(@filename, @service).and_return(true)
          expect(CMF_obj).to receive(:json_file_from_target_window?).and_return(true).at_least(:once)
          expect(CMF_obj).to receive(:puts)
          expect(CMF_obj).to receive(:stage_jsons_from_tarfile).at_least(:once)
          CMF_obj.consider_tarfile_contents_for_inclusion(real_tarfile, @service)
        end
      end
    end
  end

  describe "#stage_jsons_from_tarfile" do
    before do
      @jsons = ["/foo/one.json", "/foo/two.json"]
      @service = "puppetdb"
      @destination_dir = staging_dir + "/" + @service
    end
    context "when destination dir already exists" do
      it "unpacks the files into the destination dir" do
        expect(File).to receive(:open).and_return(true)
        expect(Zlib::GzipReader).to receive(:new).and_return(zipreader)
        expect(File).to receive(:directory?).and_return(true)
        expect(Archive::Tar::Minitar).to receive(:unpack).with(zipreader, @destination_dir, @jsons)
        CMF_obj.stage_jsons_from_tarfile(tar_name_middle_of_window, @jsons, @service)
      end
    end
    context "when destination dir does not already exist" do
      it "mkdirs the destination dir and then unpacks the files into it" do
        expect(File).to receive(:open).and_return(true)
        expect(Zlib::GzipReader).to receive(:new).and_return(zipreader)
        expect(File).to receive(:directory?).and_return(false)
        expect(FileUtils).to receive(:mkdir).with(@destination_dir).once
        expect(Archive::Tar::Minitar).to receive(:unpack).with(zipreader, @destination_dir, @jsons)
        CMF_obj.stage_jsons_from_tarfile(tar_name_middle_of_window, @jsons, @service)
      end
    end
  end

  describe "#tarfile_from_target_window?" do
    before do
      @service = "puppetdb"
    end
    it "returns false for a tarfile that doesn't match the time pattern" do
      expect(CMF_obj.tarfile_from_target_window?("/foo/bar/my.tar.gz", @service)).to eq(false)
    end
    it "returns false for a tarfile from 30h before the window" do
      expect(CMF_obj.tarfile_from_target_window?(tar_name_30h_before_window, @service)).to eq(false)
    end
    it "returns false for a tarfile from 5h before the window" do
      expect(CMF_obj.tarfile_from_target_window?(tar_name_5h_before_window, @service)).to eq(false)
    end
    it "returns true for a tarfile from inside the window" do
      expect(CMF_obj.tarfile_from_target_window?(tar_name_middle_of_window, @service)).to eq(true)
    end
    it "returns true for a tarfile from 5h after the window (but less than the poll interval after)" do
      expect(CMF_obj.tarfile_from_target_window?(tar_name_5h_after_window, @service)).to eq(true)
    end
    it "returns false for a tarfile from 30h after the window" do
      expect(CMF_obj.tarfile_from_target_window?(tar_name_30h_after_window, @service)).to eq(false)
    end
  end

  describe "#tar_metrics_files" do
    context "verbose attribute is false" do
      it "command is not run with verbose flag" do
        staging_parent = File.dirname(staging_dir)
        expect(CMF_obj).to receive(:puts).at_least(:once)
        expect(CMF_obj).to receive(:system).with("tar czf #{output_dir}/#{tar_file_name} -C #{staging_parent} .")
                                           .and_return(0)
        CMF_obj.tar_metrics_files
      end
    end
    context "verbose attribute it true" do
      before do
        CMF_obj.instance_variable_set("@verbose", true)
      end
      it "command is run with verbose flag" do
        staging_parent = File.dirname(staging_dir)
        expect(CMF_obj).to receive(:puts).at_least(:once)
        expect(CMF_obj).to receive(:system).with("tar czvf #{output_dir}/#{tar_file_name} -C #{staging_parent} .")
                                           .and_return(0)
        CMF_obj.tar_metrics_files
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
