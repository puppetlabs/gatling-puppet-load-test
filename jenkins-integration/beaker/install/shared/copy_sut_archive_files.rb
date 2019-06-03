# frozen_string_literal: true

require "fileutils"

step "Copy archive files from SUT" do
  archive_files = ENV["SUT_ARCHIVE_FILES"].split("\n")
  job_name = ENV["PUPPET_GATLING_SIMULATION_ID"]
  Beaker::Log.notify("Copying #{archive_files.count} archive files from SUT")

  archive_dir = "../puppet-gatling/#{job_name}/sut_archive_files"

  FileUtils.mkdir_p(archive_dir)

  archive_files.each do |s|
    if on(master, "test -f '#{s}'", acceptable_exit_codes: [0, 1]).exit_code.zero?
      Beaker::Log.notify("Copying archive file '#{s}'")
      scp_from(master, s, archive_dir)
    else
      Beaker::Log.warn("Not copying archive file '#{s}' as it does not seem to exist")
    end
  end
end
