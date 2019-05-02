# Saving and loading database content

In real world use the databases of a puppet install would already have a lot of data in them.  So accurate performance testing should start with data as well.  But a fresh install doesn't have any old data in the databases.  This doc describes how data can be saved from one install and loaded into another.

There are some catches though.  If you load the data, it will overwrite existing data.  Like any nodes already setup with the install or any classifications.  So it is best to do this as early as possible.  Like if you do it immediately after the master install you can run `puppet infrastructure configure` and it will pick the master back up.  Possibly other infrastructure components as well, I didn't test it.  Otherwise you can run the puppet agent on nodes to get them back into the system.  As for classification, I think you could simply not load the classification db and that might save those.

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
service pe-puppetdb stop
su - pe-postgres -s /bin/bash
#create updatetime.sql with contents shown in next section
/opt/puppetlabs/server/bin/pg_restore -cd pe-activity /tmp/saveddbs/pe-activity.backup
/opt/puppetlabs/server/bin/pg_restore -cd pe-rbac /tmp/saveddbs/pe-rbac.backup
/opt/puppetlabs/server/bin/pg_restore -cd pe-classifier /tmp/saveddbs/pe-classifier.backup
/opt/puppetlabs/server/bin/pg_restore -cd pe-puppetdb /tmp/saveddbs/pe-puppetdb.backup
/opt/puppetlabs/server/bin/pg_restore -cd pe-orchestrator /tmp/saveddbs/pe-orchestrator.backup

/opt/puppetlabs/server/bin/psql -d pe-puppetdb -a -f updatetime.sql

exit #to get back to being root
service pe-puppetdb start # as root
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