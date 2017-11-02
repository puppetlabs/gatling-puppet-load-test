require 'scooter'
include Scooter::LDAP

# Should never get here unless an "openldap" host is specified in the 
# beaker host/config file
def ldap_dispatcher
  # Scooter doesn't support custom settings yet.
  #@ldap_dispatcher ||= LDAPDispatcher.new(openldap, { :encryption => nil, :port => 389, 
  #                                                    :auth => { :method => :simple, :username => "cn=admin,dc=example,dc=com", :password => "puppetlabs" } })
  @ldap_dispatcher ||= LDAPDispatcher.new(openldap, { :encryption => nil, :port => 389 })
end
