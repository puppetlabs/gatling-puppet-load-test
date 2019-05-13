# Bolt Tasks

This repo includes bolt tasks.  The available tasks are enumerated here.

The following `bolt` commands must be executed from the root directory of a
checkout of this repository.

## gplt::create_control_repo_from_production_env

This task creates a git repo using either a path (commonly the contents from the given node's
puppet production environment) or a public GitHub URL.  Normally the specified node should be
the primary puppet master.

The task takes optional arguments which can be used to identify the source for the new git repo or
to specify the fully qualified path for where the new repo should be created.

Note: The bolt task needs to be run as the `root` user (which is the default)
in order for the default `ctrl_repo_path` to be successfully created.

The built in documentation for the task can be seen by running the following:
```
bolt task show gplt::create_control_repo_from_production_env

gplt::create_control_repo_from_production_env - Creates a local git repo for puppet code

USAGE:
bolt task run --nodes <node-name> gplt::create_control_repo_from_production_env ctrl_repo_path=<value> code_source_path=<value> code_source_url=<value> code_source_branch=<value>

PARAMETERS:
- ctrl_repo_path: Optional[String[1]]
    The fully qualified path where the control repo will be created
- code_source_path: Optional[String[1]]
    The fully qualified path to the source code
- code_source_url: Optional[String[1]]
    The URL to a public github repo that contains the source code
- code_source_branch: Optional[String[1]]
    The branch of the public github repo in code_source_url to use as production
```

Typical usage on an ABS instance would use the following bolt pattern:
```
bolt task run \
  --user root \
  --no-host-key-check \
  --private-key ~/.ssh/id_rsa-acceptance \
  --nodes ip-10-xx-xx-xx.amz-dev.puppet.net \
  gplt::create_control_repo_from_production_env \
  code_source_url="https://github.com/puppetlabs/puppetlabs-pe_perf_control_repo.git"
```
