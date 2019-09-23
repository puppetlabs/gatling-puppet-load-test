# Saving and loading database content

In real world use the databases of a Puppet installation would already have a lot of data in them, so accurate performance testing should start with data as well.  However, a fresh installation doesn't have any old data in the databases.  This document describes how data can be saved from one installation and loaded into another.

However, there are some catches. Loading the data will overwrite existing data, such as any nodes already setup with the install or any classifications, so it is best to do this as early as possible.  When loading the data immediately after the master install running `puppet infrastructure configure` will pick the master back up. Other infrastructure components may be included as well but this has not been tested. Otherwise you can run the puppet agent on nodes to get them back into the system.  As for classification, not loading the classification db might save those.

Also, just loading the data isn't enough. You need to update the timestamps so that garbage collection doesn't just toss out all the data you loaded.  That is covered in the instructions below.

## Saving DBs
Logged in as root on the master of the source install
```
su - pe-postgres -s /bin/bash
/opt/puppetlabs/server/bin/pg_dump -Fc pe-activity -f /tmp/pe-activity.backup
/opt/puppetlabs/server/bin/pg_dump -Fc pe-rbac -f /tmp/pe-rbac.backup
/opt/puppetlabs/server/bin/pg_dump -Fc pe-classifier -f /tmp/pe-classifier.backup
/opt/puppetlabs/server/bin/pg_dump -Fc pe-puppetdb -f /tmp/pe-puppetdb.backup
/opt/puppetlabs/server/bin/pg_dump -Fc pe-orchestrator -f /tmp/pe-orchestrator.backup
```


## Loading DBs
Logged in as root on the master of the target install
```
#as root
service pe-puppetdb stop
service pe-console-services stop
service pe-puppetserver stop
service pe-nginx stop
service pe-orchestration-services stop

su - pe-postgres -s /bin/bash
#create updatetime.sql with contents shown in next section
/opt/puppetlabs/server/bin/pg_restore -U pe-postgres --if-exists -cCd template1 /tmp/saveddbs/pe-activity.backup
/opt/puppetlabs/server/bin/pg_restore -U pe-postgres --if-exists -cCd template1 /tmp/saveddbs/pe-rbac.backup
/opt/puppetlabs/server/bin/pg_restore -U pe-postgres --if-exists -cCd template1 /tmp/saveddbs/pe-classifier.backup
/opt/puppetlabs/server/bin/pg_restore -U pe-postgres --if-exists -cCd template1 /tmp/saveddbs/pe-orchestrator.backup
/opt/puppetlabs/server/bin/pg_restore -U pe-postgres --if-exists -cCd template1 /tmp/saveddbs/pe-puppetdb.backup

/opt/puppetlabs/server/bin/psql -d pe-puppetdb -a -f updatetime.sql

exit #to get back to being root
service pe-console-services start
service pe-puppetserver start
service pe-nginx start
service pe-orchestration-services start
service pe-puppetdb start

puppet infrastructure configure #to fix master to be back in the database
puppet agent -t #to ensure everything worked
```

Expect the pg_restore to generate this output per db
```
pg_restore: [archiver (db)] Error while PROCESSING TOC:
pg_restore: [archiver (db)] Error from TOC entry 4; 2615 2200 SCHEMA public pe-postgres
pg_restore: [archiver (db)] could not execute query: ERROR:  schema "public" already exists
    Command was: CREATE SCHEMA public;



WARNING: errors ignored on restore: 1
```

updatetime.sql
```
DROP TABLE IF EXISTS max_report;

SELECT max(producer_timestamp)
INTO TEMPORARY TABLE max_report
FROM reports;

DROP TABLE IF EXISTS time_diff;

SELECT (DATE_PART('day', now() - (select max from max_report)) * 24 +
        DATE_PART('hour', now() - (select max from max_report))) * 60 +
        DATE_PART('minute', now() - (select max from max_report)) as minute_diff
INTO TEMPORARY TABLE time_diff;

UPDATE reports
  SET producer_timestamp = producer_timestamp + ((select minute_diff from time_diff) * INTERVAL '1 minute'),
  start_time = start_time + ((select minute_diff from time_diff) * INTERVAL '1 minute'),
  end_time = end_time + ((select minute_diff from time_diff) * INTERVAL '1 minute'),
  receive_time = receive_time + ((select minute_diff from time_diff) * INTERVAL '1 minute');

UPDATE resource_events
  SET timestamp = timestamp + ((select minute_diff from time_diff) * INTERVAL '1 minute');

UPDATE catalogs
  SET producer_timestamp = producer_timestamp + ((select minute_diff from time_diff) * INTERVAL '1 minute'),
  timestamp = timestamp + ((select minute_diff from time_diff) * INTERVAL '1 minute');

UPDATE factsets
  SET producer_timestamp = producer_timestamp + ((select minute_diff from time_diff) * INTERVAL '1 minute'),
  timestamp = timestamp + ((select minute_diff from time_diff) * INTERVAL '1 minute');

DROP TABLE IF EXISTS time_diff;
DROP TABLE IF EXISTS max_report;
```
