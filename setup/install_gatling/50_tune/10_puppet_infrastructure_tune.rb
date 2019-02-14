test_name 'Run puppet infrastructure tune' do

  def puppet_infrastructure_tune
    base_tune_command = "puppet infrastructure tune"
    common_yaml_path = "/etc/puppetlabs/code-staging/environments/production/hieradata/common.yaml"
    tune_output_dir = "tune_output"
    tune_output_path = "#{tune_output_dir}/nodes/#{master.hostname}.yaml"

    # create tune_output dir
    puts "Creating '#{tune_output_dir}' dir on master..."
    puts
    on master, "mkdir -p #{tune_output_dir}"

    # tune with hiera output and (and --force if specified)
    hiera_option = " --hiera #{tune_output_dir}"
    force_option = ENV["PUPPET_GATLING_SCALE_TUNE_FORCE"].eql?("true") ? " --force" : ""
    tune_command = base_tune_command + hiera_option + force_option
    puts "Running '#{tune_command}' on master..."
    puts
    on master, tune_command
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
    output = on(master, "#{base_tune_command} --current").output

    puts "Tune output:"
    puts output

    on master, "echo \"#{output}\" >> tune/current_tune.txt"
  end

  step 'run puppet infrastructure tune' do
    if ENV['PUPPET_GATLING_SCALE_TUNE'] == 'true'
      puppet_infrastructure_tune
    else
      puts "PUPPET_GATLING_SCALE_TUNE is not set to 'true'; skipping puppet infrastructure tune..."
    end
  end

end
