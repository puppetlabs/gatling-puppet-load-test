#!/bin/bash

set -e

# Clone repo
git clone {test_catalogs_repo_url}

# Scp to test machine
scp  -r {test_catalogs_dir} root@{machine_hostname}:/root/

rm -rf {test_catalogs_dir}

