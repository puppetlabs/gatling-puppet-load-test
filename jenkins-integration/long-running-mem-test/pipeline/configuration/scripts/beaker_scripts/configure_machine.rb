test_name "Configuring Machine"
beaker_dependencies = [
 "curl", "ntpdate", "git", "ruby", "rdoc"
]

utilities = [
 "vim", "screen"
]

# Repos
test_catalogs_repo = "git@github.com:camlow325/test-catalogs.git"

hosts.each do |host|
  # Installing packages is idempotent, so no need to check if they're already there
  step "== Install beaker dependencies"
  beaker_dependencies.each do |dependency|
    step "Installing package: #{dependency}"
    install_package host, dependency
  end

  step "== Install Utilities"
  utilities.each do |utility|
    step "Installing package: #{utility}"
    install_package host, utility
  end
end
