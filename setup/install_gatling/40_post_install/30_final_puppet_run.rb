# frozen_string_literal: true

test_name "final puppet run" do
  step "Set server to master on hosts" do
    on hosts, "puppet config set --section agent server #{master.hostname}"
  end
  step "Run puppet until all changes are applied" do
    run_agent_until_no_change(hosts)
  end
end
