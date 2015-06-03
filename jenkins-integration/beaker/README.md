# beaker
This directory holds beaker scripts that will get run as part of jenkins jobs

## install/
The `install` directory has scripts to install FOSS puppet and PE

### FOSS
Running the FOSS installer requires a couple things:
* puppetserver version: Supplied through the beaker hosts config option `puppetserver_version`, or the
  `PUPPETSERVER_BUILD_VERSION` environment variable
* puppet-agent version: Supplied through the beaker hosts config option `puppet_version`, or the
  `PUPPET_BUILD_VERSION` environment variable

These build versions should be available on the internal builds server

For example, you can either export the variables:
```bash
export PUPPETSERVER_BUILD_VERSION=2.0.0
export PUPPET_BUILD_VERSION=1.1.0
```

or specify them in a beaker host file:
```yaml
HOSTS:
  centos_box:
    platform: el-6-x86_64
    roles:
    - agent
    - master
    - database
CONFIG:
    puppetserver_version: 2.0.0
    puppet_version: 1.1.0
```

Environment variables take precedence over beaker host files

### PE
When running the PE installer, two options can be set:
* PE dist dir: Where to find the PE packages. Supplied through the beaker hosts config option `pe_dir`, or the
  `pe_dist_dir` environment variable
* PE version: Supplied through the beaker hosts config option `pe_ver`, or the
  `pe_ver` environment variable

You must at least set the PE dist dir. If `pe_ver` isn't set, it will install the latest version at the location provided by the dist dir.
