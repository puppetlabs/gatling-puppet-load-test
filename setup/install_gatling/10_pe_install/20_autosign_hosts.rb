# frozen_string_literal: true

test_name "configure autosign for hosts" do
  skip_test "Installing FOSS, not PE" unless ENV["BEAKER_INSTALL_TYPE"] == "pe"
  confdir = master.puppet["confdir"]
  hostnames = hosts.map(&:hostname)
  on master, puppet_apply, stdin: <<~MANIFEST
    file { "#{confdir}/autosign.conf":
      ensure => file,
      mode => "0644",
      owner => "pe-puppet",
      group => "pe-puppet",
      content => "#{hostnames.join("\n")}",
    }
  MANIFEST
end
