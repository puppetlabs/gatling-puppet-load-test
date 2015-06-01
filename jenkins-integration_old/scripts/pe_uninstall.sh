#!/bin/sh

MASTER=$1
SSH_KEYFILE=$2

scp -i "$SSH_KEYFILE" scripts/wipe_pe.sh root@$MASTER:/tmp/
ssh -i "$SSH_KEYFILE" root@$MASTER "/tmp/wipe_pe.sh"
