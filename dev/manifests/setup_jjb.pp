#####################
# Jenkins job builder
#####################

# Need this for pip
class { 'epel': }
->
package { 'python-pip':
  ensure => installed,
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
