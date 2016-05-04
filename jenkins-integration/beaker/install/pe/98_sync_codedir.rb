test_name 'Sync code-staging to code via File Sync'

# TODO SERVER-1144
#      This isn't quite done yet, as simply hitting the 'commit' endpoint
#      doesn't actually copy over code-staging to code. That part is happening
#      periodically by a background process.
#
#      We need to wait until the background process has actually done the sync
#      before we are done with this phase, as the expectation is that the code
#      directory is populated after this phase ends.
#
#      To do this, we'll need to:
#      1. Extract the "latest-commit.commit" SHA out of the JSON response from
#         the 'commit' endpoint.
#      2. Poll the status endpoint for file-sync-storage-service and wait until
#         the "status.repos.puppet-code.latest_commit" value matches the SHA
#         from step 1 above.

curl = 'curl '
curl += '--cert $(puppet config print hostcert) '
curl += '--key $(puppet config print hostprivkey) '
curl += '--cacert $(puppet config print localcacert) '
curl += '-H "Content-type: application/json" '
curl += "https://#{master}:8140/file-sync/v1/commit "
curl += '-d \'{"commit-all": true}\''

on(master, curl)

# TODO: improve this
# sleep for 10 minutes to make sure the file sync has completed
sleep 600
