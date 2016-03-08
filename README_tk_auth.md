## Setting up TK Auth to allow proxy recordings or simulations

Recent versions of OSS Puppet Server and PE use the new "Trapperkeeper Authorization" library to handle cert-based authorization of requests coming in to the various HTTP endpoints.

At the time of this writing, in order to capture an agent recording via the gatling proxy recorder, or to run a gatling simulation against Puppet Server / PE, you need to set up the authorization rules for TK auth to be very permissive.

Effectively, what we want to do is modify the contents of the file `/etc/puppetlabs/puppetserver/conf.d/auth.conf` to look like this:

```
authorization: {
    version: 1
    rules: [
        {
            match-request: {
                path: "/"
                type: "path"
            }
            allow-unauthenticated: true
            sort-order: 1
            name: "allow all"
        }
    ]
}
```

However, in a PE installation, if you modify the file to look like this, any subsequent agent run will end up modifying the file again and restarting the server, because the rules are being managed by the PE modules.  Having a server restart occur during your agent recording is no good and will corrupt the recording so that it's not really usable for testing.

Therefore, in PE, the easiest way to solve this is to edit the file and simply insert the permissive rule as the first entry in the pre-existing list of rules in the file.  In otherwords, you'll just insert this as the first entry in the rules array:


```
        {
            match-request: {
                path: "/"
                type: "path"
            }
            allow-unauthenticated: true
            sort-order: 1
            name: "allow all"
        },
```

After this, it's a good idea to do an agent run with `puppet agent -t` to verify that PE doesn't think it needs to modify the `auth.conf` file.

After verifying that, you will want to restart or HUP the server so that the new rules take effect.  You can test the rules by running a command like this:

   curl -k https://localhost:8140/puppet/v3/catalog/$(hostname)\?environment=production

If the auth rules haven't taken effect, this request will be rejected because you didn't pass the appropriate client cert when making the request.  If this request succeeds, then you should be ready for proxy recordings or simulations.
