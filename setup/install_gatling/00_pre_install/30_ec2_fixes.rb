
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

  step 'Download Puppet installer and set pe_dir' do
    # If the installer download is on the internal network, EC2 instance can't access it, so copy it locally.
    if master['pe_dir'] =~ /puppetlabs\.net/
      tmp_dir = Dir.mktmpdir
      # TODO: Need this to work for FOSS too
      file = "puppet-enterprise-#{master[:pe_ver]}-#{master[:platform]}.tar.gz"
      curl_cmd = "curl -o #{tmp_dir}/#{file} #{master[:pe_dir]}/#{file}"
      puts curl_cmd
      system(curl_cmd)
      hosts.each do |host|
        host[:pe_dir] = tmp_dir
      end
    end
  end
end


