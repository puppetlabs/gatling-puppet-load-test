test_name 'Setup and configure gatling proxy machine' do
  step 'install java, xauth' do
    on metric, 'yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel xauth'
  end
  step 'install scala build tool (sbt)' do
    on metric, 'rpm -ivh http://dl.bintray.com/sbt/rpm/sbt-0.13.16.rpm'
  end
  step 'install rvm, bundler' do
    on metric, 'gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3'
    on metric, 'curl -sSL https://get.rvm.io | bash -s stable --ruby=2.2.5'
    on metric, 'gem install bundler'
  end
  step 'create key for metrics to talk to primary master' do
    on metric, 'yes | ssh-keygen -q -t rsa -b 4096 -f /root/.ssh/id_rsa -N "" -C "gatling"'
  end
  step 'put keys on the primary master' do
    results = on metric, 'cat /root/.ssh/id_rsa.pub'
    key = results.stdout.strip
    on master, "echo \"#{key}\" >> /root/.ssh/authorized_keys"
    # on metric, "ssh-copy-id root@#{master.hostname}"
  end
  step 'install git' do
    on metric, 'yum install -y git'
  end
  clone_git_repo_on(metric, './', extract_repo_info_from(build_git_url('gatling-puppet-load-test')))
  step 'setup shill git user' do
    on metric, 'cd gatling-puppet-load-test; git config --global user.email "beaker@puppet.com"; git config --global user.name "meep"'
  end
  step 'copy ssl certs to metrics box' do
    on metric, 'mkdir /root/gatling-puppet-load-test/simulation-runner/target'
    scp_to(metric, 'simulation-runner/target/ssl', 'gatling-puppet-load-test/simulation-runner/target/ssl')
  end
end
