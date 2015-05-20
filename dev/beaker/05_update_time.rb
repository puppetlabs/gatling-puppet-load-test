test_name "Update time on host"

ntpdate_cmd = "ntpdate time.apple.com"

step "Run ntpdate"
on(dev_machine, ntpdate_cmd)
