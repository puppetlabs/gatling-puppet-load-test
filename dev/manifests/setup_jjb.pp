$jjb_config_dir = '/etc/jenkins_jobs'
$jjb_config_file = "${jjb_config_dir}/jenkins_jobs.ini"

#####################
# Jenkins job builder
#####################

# Need this for pip
package { 'epel-release-6-8.noarch':
  ensure => installed,
}

# Centos 6 doesn't come with pip, needed for the pip provider
package { 'python-pip':
  ensure => installed,
  require => Package['epel-release-6-8.noarch']
}

package { 'jenkins-job-builder':
  ensure => installed,
  provider => 'pip',
  require => Package['python-pip']
}


#################
# JJB Config File
#################
file { $jjb_config_dir:
  ensure => directory,
}

file { $jjb_config_file:
  ensure => file,
}

ini_setting { 'jenkins url':
  ensure  => present,
  path    => $jjb_config_file,
  section => 'jenkins',
  setting => 'url',
  value   => 'http://localhost:8080',
  require => File[$jjb_config_file]
}
