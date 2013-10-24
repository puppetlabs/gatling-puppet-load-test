#!/bin/sh

MASTER=$1

scp scripts/wipe_pe.sh root@$MASTER:/tmp/
ssh root@$MASTER "/tmp/wipe_pe.sh"
