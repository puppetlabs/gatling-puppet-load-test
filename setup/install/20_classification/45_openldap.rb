require 'classification_helper'
require 'ldap_helper'

# Create the openldap group in the classifier
# Scooter requires the databases, rootdn, and rootpw as they are.
def add_openldap_group
  if any_hosts_as?(:openldap)
    openldap_group = {
      'name'    => "OpenLDAP Server",
      'rule'    => ["or", ["=", "name", openldap.node_name]], # pinned node
      'parent'  => pe_infra_uuid,
      'classes' => {
        'openldap::server' => {
          'databases' => { 'dc=delivery,dc=puppetlabs,dc=net' => {
              'rootdn' => 'cn=admin,dc=delivery,dc=puppetlabs,dc=net',
              'rootpw' => 'Puppet11'
            }
          }
        }
      }
    }

    dispatcher.find_or_create_node_group_model(openldap_group)
  end
end

test_name 'Add OpenLDAP classification' do
  skip_test "No OpenLDAP servers to classify" unless any_hosts_as?(:openldap)

  step 'add OpenLDAP classification' do
    add_openldap_group
  end
end

test_name 'Setup OpenLDAP Server' do
  skip_test "No OpenLDAP Server" unless any_hosts_as?(:openldap)

  step 'install OpenLDAP on openldap' do
    on openldap, puppet_agent('-t'), :acceptable_exit_codes => [0,2]
  end
end

test_name 'Setup LDAP users and groups' do
  step 'Setting up required LDIF files' do
    on openldap, "/usr/bin/ldapadd -Q -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/core.ldif", :acceptable_exit_codes => [0,80]
    on openldap, "/usr/bin/ldapadd -Q -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif"
    on openldap, "/usr/bin/ldapadd -Q -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif"
  end
  step 'Setting up LDAP groups and users' do
    ldap_dispatcher.create_ou_for_users_and_groups
    users    = options[:openldap_users] || 20
    groups   = options[:openldap_groups] || 7
    u_per_g  = users / groups
    index = 1
    for i in 1..users
      ldap_dispatcher.create_ds_user( :cn => "padmin_#{i}", :sn => "someguy" )
    end
    for i in 1..groups
      users = Array.new
      for j in 1..u_per_g
        users.push("cn=padmin_#{index},#{ldap_dispatcher.users_dn}")
        index += 1
      end
      ldap_dispatcher.create_ds_group( :cn => "pgroup_#{i}", :uniqueMember => users )
    end
  end
end

test_name 'Connect RBAC to LDAP' do
  dispatcher.attach_ds_to_rbac(ldap_dispatcher, "ssl" => false)
end
