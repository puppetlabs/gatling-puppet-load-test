test_name 'Run puppet infrastructure tune' do

  def run_puppet_infrastructure_tune
    common_yaml = "/etc/puppetlabs/code-staging/environments/production/hieradata/common.yaml"

    puts "Running 'puppet infrastructure tune' on master..."
    puts

    output = on(master, "puppet infrastructure tune").output

    # get data between '---' and the first empty line
    data = output.match(/## Specify(.*)## CPU/m)[1].gsub("---", "").strip

    # remove control codes
    data = data.match(/0;32m(.*)\n.*\[/m)[1].strip + "\n"

    puts "Extracted the following data:"
    puts data

    puts "Appending to common.yml"
    puts
    on master, "echo \"#{data}\" >> #{common_yaml}"

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
  end

  step 'run puppet infrastructure tune' do
    if ENV['SCALE_TUNE'] == 'true'
      run_puppet_infrastructure_tune
    else
      puts "SCALE_TUNE is not set to 'true'; skipping puppet infrastructure tune..."
    end

  end

end
