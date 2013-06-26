#!/bin/sh

MASTER=$1

scp ../simulation-runner/acceptance/bin/wipe_pe.sh root@$MASTER:/tmp/
ssh root@$MASTER "/tmp/wipe_pe.sh"
