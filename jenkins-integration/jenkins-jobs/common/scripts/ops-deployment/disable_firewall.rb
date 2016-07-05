step "disable firewall" do
  # TODO: use puppet?  service resource? something more reusable anyway
  on(master, "systemctl stop firewalld")
  on(master, "systemctl disable firewalld")
end
