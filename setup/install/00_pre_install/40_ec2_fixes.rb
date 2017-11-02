
def cloud_config(host)
  if host.file_exist?("/etc/cloud/cloud.cfg")
    on host, "if grep 'preserve_hostname: true' /etc/cloud/cloud.cfg ; then echo 'already set' ; else echo 'preserve_hostname: true' >> /etc/cloud/cloud.cfg ; fi"
  end
end

test_name 'Workaround various EC2 host config issues.' do
  step 'Fix cloud.cfg' do
    hosts.each do |host|
      cloud_config(host)
    end
  end
end

