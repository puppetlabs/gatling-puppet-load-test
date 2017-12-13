test_name 'Configure permissive auth on Puppet Server'

step 'Configure permissive auth.conf on master' do
  supports_tk_auth = ENV['PUPPET_SERVER_TK_AUTH'] == 'true'

  if supports_tk_auth
    Beaker::Log.notify "Server supports tk auth, configuring."

    auth_conf = '/etc/puppetlabs/puppetserver/conf.d/auth.conf'
    create_remote_file(master, auth_conf, <<-EOF)
authorization: {
    version: 1
    rules: [
        {
            match-request: {
                path: "/"
                type: path
            }
            allow-unauthenticated: true
            sort-order: 1
            name: "Puppet Gatling Load Test -- allow all"
        }
    ]
}
    EOF
  else
    Beaker::Log.notify "Server does not support tk auth, configuring legacy auth.conf"

    auth_conf = '/etc/puppetlabs/puppet/auth.conf'
    create_remote_file(master, auth_conf, <<-EOF)
path /
auth any
allow *
    EOF

  end


end
