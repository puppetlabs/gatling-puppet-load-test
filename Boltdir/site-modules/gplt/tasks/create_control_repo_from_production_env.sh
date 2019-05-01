#!/bin/bash

set -e

CTRL_REPO_PATH="${PT_ctrl_repo_path:-/opt/puppet/control-repo.git}"
[ -z "$CTRL_REPO_PATH" ] && echo "Must specify a control repo path" && exit 1

CTRL_REPO_BASEDIR=$(dirname $CTRL_REPO_PATH)

ENVIRONMENT=production
PUPPET_PROD_ENV_DIR=/etc/puppetlabs/code/environments/$ENVIRONMENT
CHECKOUT_DIR=/tmp/control-repo


mkdir -p "$CTRL_REPO_BASEDIR"

if [ -d "$CTRL_REPO_PATH" ]; then
    echo "ERROR: The control repo destination already exists" >&2
    exit 1
fi

git init --bare $CTRL_REPO_PATH
git clone $CTRL_REPO_PATH $CHECKOUT_DIR
cp -r $PUPPET_PROD_ENV_DIR/* $CHECKOUT_DIR
rm -fr $CHECKOUT_DIR/modules
cd $CHECKOUT_DIR \
    || { echo "ERROR: Failed to cd into $CHECKOUT_DIR" >&2 ; exit 1 ; }
git add .
git commit -m "Initial commit"
git branch -m $ENVIRONMENT
git push -u origin $ENVIRONMENT
cd $CTRL_REPO_PATH
git symbolic-ref HEAD refs/heads/$ENVIRONMENT

rm -rf $CHECKOUT_DIR

# send structured data to bolt
printf '{"control_repo_path":"%s"}\n' "$CTRL_REPO_PATH"
