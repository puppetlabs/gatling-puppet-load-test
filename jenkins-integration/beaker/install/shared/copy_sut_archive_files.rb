require 'fileutils'

step "Copy archive files from SUT" do
  archive_files = ENV['SUT_ARCHIVE_FILES'].split("\n")
  Beaker::Log.notify("Copying #{archive_files.count} archive files from SUT")

  FileUtils.mkdir_p("./sut_archive_files")

  archive_files.each do |s|
    Beaker::Log.notify("Copying archive file '#{s}'")
    scp_from(master, s, "./sut_archive_files")
  end
end
