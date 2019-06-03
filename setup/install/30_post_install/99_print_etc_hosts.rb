# frozen_string_literal: true

# retrieve the public IP address for a single host
def public_ip_address(host)
  if host["hypervisor"] == "ec2"
    curl_on(host, "http://169.254.169.254/latest/meta-data/public-ipv4").stdout.chomp
  else
    host.ip
  end
end

# retrieve public IPv4 addresses for each host
def host_ips(hosts)
  hosts.each_with_object({}) do |host, results|
    results[host.hostname] = public_ip_address(host)
  end
end

test_name "print /etc/hosts info" do
  step "print /etc/hosts info" do
    ip_mapping = host_ips(hosts)
    @logger.info "---------------------"
    @logger.info "instance IP -> hostname info for /etc/hosts"
    @logger.info "--------------------"
    @logger.info ""
    ip_mapping.each_pair do |hostname, ip|
      @logger.info "#{ip}\t#{hostname}"
    end
  end
end
