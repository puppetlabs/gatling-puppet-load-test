# frozen_string_literal: true

test_name "Configure code manager" do
  configure_code_manager
  on(master, puppet("agent", "-t"), acceptable_exit_codes: [0, 2])
  on(compile_master, puppet("agent", "-t"), acceptable_exit_codes: [0, 2]) if any_hosts_as?("compile_master")
  cm_deploy_all_envs
end
