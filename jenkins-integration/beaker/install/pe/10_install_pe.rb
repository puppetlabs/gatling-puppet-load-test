# frozen_string_literal: true

test_name "Install PE"

# Environment variables:
#   (required) pe_dir="https://artifactory.delivery.puppetlabs.net/artifactory/generic_enterprise__local/2016.2/ci-ready/"
#   (optional) pe_ver="2016.2.0-rc0"
#
# The environment variables need to be specified on the CLI when invoking beaker,
# or alternately they can be set on the master host in the hosts.yaml file.

install_pe_on(master, options)
