test_name 'Run puppet infrastructure tune' do

  def puppet_infrastructure_tune

    common_yaml_path = "/etc/puppetlabs/code-staging/environments/production/hieradata/common.yaml"
    tune_output_path = "tune/nodes/#{master.hostname}.yaml"

    # create tune dir for output
    on master, "mkdir -p tune"

    puts "Running 'puppet infrastructure tune' on master..."
    puts

    # tune with hiera output
    on master, "puppet infrastructure tune --force --hiera tune"
    tune_output = on(master, "cat #{tune_output_path}").output.gsub("---", "") + "\n"

    puts "Extracted the following output:"
    puts tune_output
    puts

    puts "Appending to common.yml"
    puts
    on master, "echo \"#{tune_output}\" >> #{common_yaml_path}"

    puts "Committing..."
    puts
    commit = "curl --request POST --header \"Content-Type: application/json\" --data '{\"commit-all\": true}' --cert $(puppet config print hostcert) --key $(puppet config print hostprivkey) --cacert $(puppet config print localcacert) https://$(hostname):8140/file-sync/v1/commit"
    on master, commit

    begin
      on master, "puppet agent -t"
    rescue
      puts "Expected non-zero exit code, running again..."
      on master, "puppet agent -t"
    end

    # output current tune
    puts "Checking current tune:"
    puts
    output = on(master, "puppet infrastructure tune --current").output

    puts "Tune output:"
    puts output

    on master, "echo \"#{output}\" >> tune/current_tune.txt"

  end

  step 'run puppet infrastructure tune' do
    if ENV['SCALE_TUNE'] == 'true'
      puppet_infrastructure_tune
    else
      puts "SCALE_TUNE is not set to 'true'; skipping puppet infrastructure tune..."
    end

  end

end
