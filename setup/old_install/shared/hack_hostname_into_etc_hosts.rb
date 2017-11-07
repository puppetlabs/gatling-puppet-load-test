step "Hack hostname into /etc/hosts" do
  # TODO: this should be able to go away once we get DNS working on the SUTs
  # if we do need to keep it, it needs to be made to be way less fragile
  on(master, 'echo -e "`hostname -I`\t`hostname`" >> /etc/hosts')
end
