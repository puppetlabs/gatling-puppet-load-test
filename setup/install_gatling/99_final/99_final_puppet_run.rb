# frozen_string_literal: true

test_name "final puppet run" do
  step "Run puppet until all changes are applied" do
    run_agent_until_no_change(hosts)
  end
  step "Ensure puppet agent disabled" do
    # If deployed via install_pe this is part of the install.
    #   Ref: https://github.com/puppetlabs/beaker-pe/blob/master/lib/beaker-pe/install/pe_utils.rb
    # This is added to ensure that the puppet agent service is
    # disabled prior to a gatling run regardless of how the hosts
    # were deployed.
    stop_agent_on(hosts)
  end
end
