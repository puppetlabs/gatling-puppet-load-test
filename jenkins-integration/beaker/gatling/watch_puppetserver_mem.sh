#!/bin/bash

# This script outputs the memory usage of puppet server every $delay seconds
# Example usage: watch_puppetserver_mem.sh 20 > logfile.csv
#
# Example output: 
#  time,mem
#  10,2000
#  20,2100
#  30,2150


delay=10
if [ "$1" != "" ]
then
   delay=$1
fi

# Output PID
echo $$ > watch_puppetserver_mem.pid

# Dummy value
origpid="firstpid"

# What process to look for
process_name="puppet-server"

while sleep $delay;
do
   puppetserver_pid=`ps -ef | grep -i java | grep -i $process_name | awk '{print $2}'`

   # Only runs once at the beginning
   if [ "$origpid" != "$puppetserver_pid" ]
   then
      origpid=$puppetserver_pid
      start=`date +%s`
      if [ "$puppetserver_pid" == "" ]
      then
         # Either output error
         echo "Program does not appear to be running"
      else
         # Or output CSV headers
         echo "time,mem";
      fi
   fi
   if [ "$puppetserver_pid" != "" ]
   then
      mem_used=`ps -o rss $puppetserver_pid | awk 'NR==2'`
      mem_used=`echo "scale=2; $mem_used / 1024" | bc -l`
      now=`date +%s`
      elapsed=$((now-start))
      echo "$elapsed,$mem_used";
   fi
done

