test_name 'final puppet run' do
  step "run puppet on all nodes" do
    on hosts, 'puppet agent -t', :acceptable_exit_codes => [0, 2, 6]
  end
end
