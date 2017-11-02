require 'fileutils'

step "Copy archive files from SUT" do
  archive_files = ENV['SUT_ARCHIVE_FILES'].split("\n")
  job_name = ENV['PUPPET_GATLING_SIMULATION_ID']
  Beaker::Log.notify("Copying #{archive_files.count} archive files from SUT")

  archive_dir = "../puppet-gatling/#{job_name}/sut_archive_files"

  FileUtils.mkdir_p(archive_dir)

  archive_files.each do |s|
    Beaker::Log.notify("Copying archive file '#{s}'")
    scp_from(master, s, archive_dir)
  end
end
