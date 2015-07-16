test_name "Start memory watching script on SUT"

simulation_id = ENV['GATLING_SIMULATION_ID']
logger_refresh = ENV['MEMORY_WATCHER_REFRESH'] || 300

if not simulation_id
  abort "GATLING_SIMULATION_ID environment variable required"
end

remote_logger_dir = "/root/#{simulation_id}_memory_usage"
logger_script = "watch_puppetserver_mem.sh"

# Seconds between memory usage measurements
logger_local_path = "beaker/gatling/#{logger_script}"
script_remote_path = "#{remote_logger_dir}/#{logger_script}"
logger_cmd = "#{script_remote_path} #{logger_refresh}"

step "Create directory on SUT for memory usage log"
on(master, "mkdir -p #{remote_logger_dir}")

step "Send memory watcher script to SUT"
scp_to(master, logger_local_path, script_remote_path)

step "Start memory watching script on SUT"

# Redirect output of script to file, run in the background with nohup
on(master, "nohup #{logger_cmd} &> #{remote_logger_dir}/#{simulation_id}_memory_usage.csv &")
