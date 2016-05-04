test_name 'Configure permissive auth on Puppet Server'

step 'Configure permissive auth.conf on master' do
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
end
