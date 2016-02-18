############################################################
# WARNING:                                                 #
#   Be aware of PUP-3829 pip package provider broken on EL #
############################################################

# TODO We should probably assert that we're running against a CentOS 6 machine
#      because these resources are very specific to that platform. We could
#      probably just check some OS facter fact for determing the platform, and
#      fail if it's not CentOS 6.

class { 'epel': }
->
yumrepo { 'IUS':
  baseurl  => 'http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/',
  descr    => 'Repo with Python 3 packages',
  enabled  => 1,
  gpgcheck => 0,
}
->
package { 'python34u-pip':
  ensure => installed,
}
->
file { '/usr/bin/pip-python':
  # WORKAROUND for PUP-3829
  ensure => 'link',
  target => '/usr/bin/pip3',
}
->
package { 'jenkins-job-builder':
  ensure   => installed,
  provider => 'pip',
}

#################
# JJB Config File
#################

$jjb_config_dir = '/etc/jenkins_jobs'
$jjb_config_file = "${jjb_config_dir}/jenkins_jobs.ini"

file { $jjb_config_dir:
  ensure => directory,
}
->
file { $jjb_config_file:
  ensure => file,
}
->
ini_setting { 'jenkins url':
  ensure  => present,
  path    => $jjb_config_file,
  section => 'jenkins',
  setting => 'url',
  value   => 'http://localhost:8080',
}
