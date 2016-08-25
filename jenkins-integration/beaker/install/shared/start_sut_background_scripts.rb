require 'json'

step "Launch background scripts on SUT" do
  bg_scripts = ENV['SUT_BACKGROUND_SCRIPTS'].split("\n")
  Beaker::Log.notify("Launching #{bg_scripts.count} background scripts")
  master_tempdir = master.tmpdir('gplt_bg_scripts')
  pids = {}
  bg_scripts.each do |s|
    script_filename = File.basename(s)
    remote_path = File.join(master_tempdir, script_filename)

    Beaker::Log.notify("Launching script '#{s}'")
    scp_to(master, s, master_tempdir)
    result = on(master, "#{remote_path} > #{master_tempdir}/stdout.log 2> #{master_tempdir}/stderr.log & echo $!")
    Beaker::Log.notify("GOT RESULT FROM SCRIPT EXECUTION: '#{result}'")
    Beaker::Log.notify("\tEXIT CODE: '#{result.exit_code}'")
    Beaker::Log.notify("\tSTDOUT: '#{result.stdout}'")
    Beaker::Log.notify("\tSTDERR: '#{result.stderr}'")
    pid = result.stdout.chomp
    pids[s] = pid
  end

  Beaker::Log.notify("All bg scripts launched; saving pids to bg_pids.json")
  File.open("bg_pids.json", "w") do |f|
    f.write(JSON.pretty_generate(pids))
  end
  Beaker::Log.notify(File.read("bg_pids.json"))
end
