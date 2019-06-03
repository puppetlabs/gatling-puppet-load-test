# frozen_string_literal: true

require "json"

step "Stop background scripts on SUT" do
  pids = JSON.parse(File.read("bg_pids.json"))

  Beaker::Log.notify("Stopping #{pids.count} background scripts")
  Beaker::Log.notify(JSON.pretty_generate(pids))
  pids.each do |k, v|
    Beaker::Log.notify("Stopping script '#{k}' with pid '#{v}'")
    on(master, "kill #{v}", acceptable_exit_codes: [0, 1])
    Beaker::Log.notify("Waiting for bg script '#{k}' with pid '#{v}' to exit.")
    on(master, "while kill -0 #{v} 2>/dev/null; do sleep 0.5; done")
  end
end
