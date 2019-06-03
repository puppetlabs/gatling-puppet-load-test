# frozen_string_literal: true

require "scooter"
include Scooter::LDAP # rubocop:disable Style/MixinUsage

# Should never get here unless an "openldap" host is specified in the
# beaker host/config file
def ldap_dispatcher
  @ldap_dispatcher ||= LDAPDispatcher.new(openldap, encryption: nil, port: 389)
end
