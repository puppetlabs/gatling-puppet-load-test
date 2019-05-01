# Bolt Tasks

This repo includes bolt tasks.  The available tasks are enumerated here.

The following `bolt` commands must be executed from the root directory of a
checkout of this repository.

## gplt::create_control_repo_from_production_env

This task creates a git repo using the contents from the given node's
puppet production environment.  Therefore, the specified node should be
the primary puppet master.

The task takes one optional argument `ctrl_repo_path=<value>` which is used
as the fully qualified path for creating the git repository.

Note: The bolt task needs to be run as the `root` user (which is the default)
in order for the default `ctrl_repo_path` to be successfully created.

The built in documentation for the task can be seen by running the following:
```
bolt task show gplt::create_control_repo_from_production_env

gplt::create_control_repo_from_production_env - Creates a git repo from puppet production environment directory

USAGE:
bolt task run --nodes <node-name> gplt::create_control_repo_from_production_env ctrl_repo_path=<value>

PARAMETERS:
- ctrl_repo_path: String[1]
    The fully qualified path to be used for creating the control repo
```

Typical usage on an ABS instance would use the following bolt pattern:
```
bolt task run \
  --user root \
  --no-host-key-check \
  --private-key ~/.ssh/id_rsa-acceptance \
  --nodes ip-10-xx-xx-xx.amz-dev.puppet.net \
  gplt::create_control_repo_from_production_env \
  ctrl_repo_path="/opt/puppet/control-repo.git"
```
