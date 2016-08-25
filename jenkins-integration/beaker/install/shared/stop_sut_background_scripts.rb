require 'json'

step "Stop background scripts on SUT" do
  pids = JSON.parse(File.read("bg_pids.json"))

  Beaker::Log.notify("Stopping #{pids.count} background scripts")
  Beaker::Log.notify(JSON.pretty_generate(pids))
  pids.each do |k, v|
    Beaker::Log.notify("Stopping script '#{k}' with pid '#{v}'")
    on(master, "kill #{v}")
  end
end
