require 'fileutils'

step "Copy archive files from SUT" do
  archive_files = ENV['SUT_ARCHIVE_FILES'].split("\n")
  job_name = ENV['PUPPET_GATLING_JOB_NAME']
  Beaker::Log.notify("Copying #{archive_files.count} archive files from SUT")

  FileUtils.mkdir_p("./sut_archive_files/#{job_name}")

  archive_files.each do |s|
    Beaker::Log.notify("Copying archive file '#{s}'")
    scp_from(master, s, "./sut_archive_files/#{job_name}")
  end
end
