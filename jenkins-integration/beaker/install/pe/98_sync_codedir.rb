test_name 'Sync code-staging to code via File Sync'

# Do a File Sync commit
curl = 'curl '
curl += '--cert $(puppet config print hostcert) '
curl += '--key $(puppet config print hostprivkey) '
curl += '--cacert $(puppet config print localcacert) '
curl += '-H "Content-type: application/json" '
curl += "https://#{master}:8140/file-sync/v1/commit "
curl += '-d \'{"commit-all": true}\''

on(master, curl)

# TODO: DRY
# This code hits the file sync 'force sync' endpoint, which will hopefully
# trigger a synchronous sync of the files.  Ideally that means that when
# this curl command returns, we know that the sync is complete and that the
# files have been deployed successfully.
curl = 'curl '
curl += '-X POST '
curl += '--cert $(puppet config print hostcert) '
curl += '--key $(puppet config print hostprivkey) '
curl += '--cacert $(puppet config print localcacert) '
curl += '-H "Content-type: application/json" '
curl += "https://#{master}:8140/file-sync/v1/force-sync "

on(master, curl)
