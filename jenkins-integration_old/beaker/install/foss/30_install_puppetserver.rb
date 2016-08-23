test_name "Install puppetserver"

# Installs the version specified by PUPPETSERVER_BUILD_VERSION, by virtue
# of that being the only version available after setting up the dev
# repos
install_package master, 'puppetserver'
