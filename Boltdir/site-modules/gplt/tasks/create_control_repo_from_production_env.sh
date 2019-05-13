#!/bin/bash

#sends all stderr to stdout to be sure it gets seen. (Bolt hides stderr if there is anything on stdout)
exec 2>&1

#fail the script if any command fails
set -e

#input arg checking
[[ $PT_code_source_path ]] && [[ $PT_code_source_url ]] && \
echo "Only one source allowed, can't give both a code_source_path and code_source_url" && exit 1

[[ $PT_code_source_branch ]] && [[ $PT_code_source_path ]] && \
echo "A code_source_branch has no meaning with a code_source_path" && exit 1

[[ $PT_code_source_branch ]] && [ -z "PT_code_source_url" ] && \
echo "code_source_url is required if a code_source_branch is specified" && exit 1

#currently we only create the production env in the new repo
ENVIRONMENT=production

PUPPET_PROD_ENV_DIR=/etc/puppetlabs/code/environments/$ENVIRONMENT

#TODO would like to see this randomized to avoid conflicts with previous failed runs of this task
CHECKOUT_DIR=/tmp/control-repo

CTRL_REPO_PATH="${PT_ctrl_repo_path:-/opt/puppet/control-repo.git}"
[ -z "$CTRL_REPO_PATH" ] && echo "Must specify a control repo path" && exit 1

CODE_SOURCE_PATH="${PT_code_source_path:-/etc/puppetlabs/code/environments/$ENVIRONMENT}"
CODE_SOURCE_URL=${PT_code_source_url}
CODE_SOURCE_BRANCH=${PT_code_source_branch}

CTRL_REPO_BASEDIR=$(dirname $CTRL_REPO_PATH)

mkdir -p "$CTRL_REPO_BASEDIR"

if [ -d "$CTRL_REPO_PATH" ]; then
    echo "ERROR: The control repo destination already exists: $CTRL_REPO_PATH" >&2
    exit 1
fi

if [ -d "$CHECKOUT_DIR" ]; then
    echo "ERROR: Temporary checkout dir already exists: $CHECKOUT_DIR" >&2
    exit 1
fi

git init --bare $CTRL_REPO_PATH
git clone $CTRL_REPO_PATH $CHECKOUT_DIR
cd $CHECKOUT_DIR \
    || { echo "ERROR: Failed to cd into $CHECKOUT_DIR" >&2 ; exit 1 ; }
if [[ $CODE_SOURCE_URL ]]
then
  git pull $CODE_SOURCE_URL $CODE_SOURCE_BRANCH
else
  cp -r $PUPPET_PROD_ENV_DIR/* $CHECKOUT_DIR
  rm -fr $CHECKOUT_DIR/modules
  git add .
  git commit -m "Initial commit"
fi
git branch -m $ENVIRONMENT
git push -u origin $ENVIRONMENT
cd $CTRL_REPO_PATH
git symbolic-ref HEAD refs/heads/$ENVIRONMENT

rm -rf $CHECKOUT_DIR

# send structured data to bolt
printf '{"control_repo_path":"%s"}\n' "$CTRL_REPO_PATH"
