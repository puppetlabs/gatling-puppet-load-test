test_name 'use internal ips on the metric node' do
  step "modify /etc/hosts to use internal ip" do
    hosts.each do |host|
      if host[:private_ip]
        manifest =<<-EOS.gsub /^\s+/, ""
          host { '#{host.hostname}':
            \tensure       => present,
            \tip           => '#{host[:private_ip]}',
          }
        EOS
        apply_manifest_on(metric, manifest)
      end
    end
  end
end
