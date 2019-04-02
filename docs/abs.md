# Always be Scheduling (ABS)

**NOTE: This facility is not publically available and can only be used by
personnel employed by Puppet the company.**

[Always be Scheduling](https://github.com/puppetlabs/always-be-scheduling)
is a host scheduler to ensure that hosts are returned to the requester as
quickly as possible.  Requests are queued in order to fill them on in the
order in which they were received.
The
[`awsdirect`](https://github.com/puppetlabs/always-be-scheduling#apiv2awsdirect)
API can also be used to bypass the queue processor.


## Finding ABS

ABS is hosted within puppetlabs and managed by mesosphere.  The
[mesosphere marathon](https://github.com/mesosphere/marathon)
orchestrator can be queried to discover what FQDN names are being used for the
ABS application.  This information can be found
[here](http://leader.cinext-prod.mesos:8080/ui/#/apps/%2Falways-be-scheduling/configuration).

Once, the FQDN name for the ABS application are determined. The
[documented API endpoints](https://github.com/puppetlabs/always-be-scheduling#api-endpoints)
can be used to interact with ABS.


## Setting up token for Gatling testing

Before you can use ABS in the context of running the rake tasks for Gatling
testing in this repo, you must generate an ABS token for your user and insert
it into a `$HOME/.fog` file for consumption.


## Obtaining a token

Assuming that the marathon query for the ABS application revealed that the
hostname `cinext-abs.delivery.puppetlabs.net` is serving ABS, you can insert
that value into the standard API call for
[generating a token](https://github.com/puppetlabs/always-be-scheduling#post-token).

The `user.name` placeholder should be replaced by your LDAP user name.  When
prompted, enter the password associated with your LDAP user.
```
$ curl -X POST -d '' -u user.name --url https://cinext-abs.delivery.puppetlabs.net/api/v2/token
Enter host password for user 'user.name':
```

Once the password has been entered, ABS should return a token value

```
{
    "ok": true,
    "token": "supersecrettoken"
}
```


## Add token to .fog file

The tools in this repo use [fog](http://fog.io/) to manage access to cloud
resources for the provisioning of hosts.  ABS is one of these cloud resources,
so you need to place your ABS access token into your `$HOME/.fog` configuration
file in order for the tooling to seamlessly connect to ABS on your behalf.

Since this file contains sensitive tokens, you should ensure that the
permissions of this file are restricted to just your user.

```
touch $HOME/.fog
chmod 600 $HOME/.fog
```

The format for the ABS entry is as follows:
```
:default:
  :abs_token: supersecrettoken
```

Once the ABS token has been added to your `$HOME/.fog` file, you can proceed
to use the [rake tasks](/NEW_README.md) in this repo.
