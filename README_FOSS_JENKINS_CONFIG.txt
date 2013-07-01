Here's the basic jenkins config for a FOSS job (this will become
irrelevant as soon as we move the setup / driver logic out
of jenkins and into the source tree):

-----------------------------------------------------------
###################
# UNINSTALL PUPPET
###################
#echo "Skipping uninstall step"
#exit 0
###################

scp ./simulation-runner/acceptance/bin/wipe_foss_puppet.sh root@pe-centos6:/tmp/
ssh root@pe-centos6 "/tmp/wipe_foss_puppet.sh"

------------------------------------------------------------
#######################
# INSTALL PUPPETMASTER
#######################

rm -rf puppet-acceptance
git clone git://github.com/puppetlabs/puppet-acceptance.git
cd puppet-acceptance
git checkout 65b8f5cf913192dafbf2bda8a9a32cadee54398a

# feeling extra dirty - temporary until job is moved to jenkins-enterprise
cat > config/nodes/gatling-perf-master.cfg << EOF
HOSTS:
  pe-centos6:
    roles:
      - master
      - agent
      - database
    platform: el-6-x86_64
CONFIG:
  consoleport: 443
EOF

./systest.rb \
  --config config/nodes/gatling-perf-master.cfg \
  --puppet origin/master \
  --facter origin/master \
  --hiera origin/master \
  --type git \
  --no-color \
  --xml \
  --debug \
  --install-only

ssh root@pe-centos6 "[ -d /etc/puppet/modules ] || mkdir /etc/puppet/modules"

--------------------------------------------------------------
#######################
# RESTART PUPPETMASTER
#######################

ssh root@pe-centos6 "killall -w puppet || true"
ssh root@pe-centos6 "puppet master"

--------------------------------------------------------------
Inject Environment Variables

PUPPET_GATLING_SIMULATION_ID=foo
PUPPET_GATLING_MASTER_BASE_URL=https://pe-centos6.localdomain:8140
PUPPET_GATLING_SIMULATION_CONFIG=./config/scenarios/foss322_vanilla_1agent_cent6.json

--------------------------------------------------------------
##########################
# SETUP NODES AND CLASSES
##########################

export IS_PE=false
cd puppet-acceptance

######
#exit 0
######

./systest.rb -c config/nodes/gatling-perf-master.cfg --type manual --no-color --xml --debug --preserve-hosts --no-install -t ../simulation-runner/acceptance/setup

--------------------------------------------------------------
Build Using sbt

sbt launch
JVM Flags: -Xss2M
sbt Flags: -Dsbt.log.noformat=true
Actions: run
Sub-directory Path: simulation-runner

---------------------------------------------------------------
###################
# UNINSTALL PUPPET
###################
#echo "Skipping uninstall step"
#exit 0
###################

scp ./simulation-runner/acceptance/bin/wipe_foss_puppet.sh root@pe-centos6:/tmp/
ssh root@pe-centos6 "/tmp/wipe_foss_puppet.sh"

----------------------------------------------------------------
Post-build Actions

Track Gatling load simulation
