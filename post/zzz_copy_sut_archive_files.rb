require 'fileutils'
require 'time'

step "Copy archive files from SUT" do
  now = Time.now.getutc.to_i
  # truncate the job name so it only has the name-y part and no parameters
  if ENV['JOB_NAME']
    job_name = ENV['JOB_NAME']
                   .sub(/[A-Z0-9_]+=.*$/, '')
                   .gsub(/[\/,.]/, '_')[0..200]
  else
    job_name = 'unknown_or_dev_job'
  end

  archive_name = "#{job_name}__#{ENV['BUILD_ID']}__#{now}__perf-files.tgz"
  archive_root = "PERF_#{now}"

  # Archive the gatling result htmls from the metrics box and the atop results from the master (which are already copied locally)
  if (Dir.exist?("tmp/atop/#{@@session_timestamp}/#{master.hostname}"))
    FileUtils.mkdir_p "#{archive_root}/#{master.hostname}"
    FileUtils.cp_r "tmp/atop/#{@@session_timestamp}/#{master.hostname}", "#{archive_root}/#{master.hostname}"
    archive_file_from(metric, '/root/gatling-puppet-load-test/simulation-runner/results', {}, archive_root, archive_name)
  end

end
