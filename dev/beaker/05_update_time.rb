test_name "Update time on host"

on(jenkins, "ntpdate time.apple.com")
