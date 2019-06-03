# frozen_string_literal: true

test_name "use internal ips on the metric node" do
  step "modify /etc/hosts to use internal ip" do
    hosts.each do |host|
      next unless host[:private_ip]

      manifest = <<-MANIFEST.gsub(/^\s+/, "")
          host { '#{host.hostname}':
            \tensure       => present,
            \tip           => '#{host[:private_ip]}',
          }
      MANIFEST
      apply_manifest_on(metric, manifest)
    end
  end
end
