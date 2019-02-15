test_name "setup gitlab control repo" do

  # you must log in first
  step "set up control repo" do
    command = "cd gitlab && chmod 777 gitlab_control_repo_setup.sh && ./gitlab_control_repo_setup.sh"
    puts command
    on gitlab, command
  end

end
