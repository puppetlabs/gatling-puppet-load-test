# CentOS 6 comes with ruby 1.8.7, but this version is too old for running our
# beaker scripts so we need to install ruby 1.9.3.
#
# Since we're not upgrading the built-in system ruby, this provides a sort of
# 'shim' for conveniently running against the 1.9.3 ruby. For example, to run
# your command under the ruby193 installation: "ruby193 bundle exec beaker ..."

package { 'centos-release-SCL':
  ensure          => installed,
  install_options => [{'--enablerepo' => 'extras'}],
}
->
package { 'ruby193-ruby-devel':
  ensure => installed,
}
->
package { 'gcc-c++':
  # Needed for building native ruby extensions
  ensure => installed,
}
->
file { '/usr/bin/ruby193':
  # Install a convenience shim for executing under ruby 1.9.3
  ensure  => present,
  mode    => 0777,
  content =>
'#!/bin/bash

export PATH=/opt/rh/ruby193/root/usr/bin:/opt/rh/ruby193/root/usr/local/bin:${PATH}
export LD_LIBRARY_PATH=/opt/rh/ruby193/root/usr/lib64:${LD_LIBRARY_PATH}
export PKG_CONFIG_PATH=/opt/rh/ruby193/root/usr/lib64/pkgconfig:${PKG_CONFIG_PATH}

"$@"',
}
->
exec { 'install bundler':
  command => '/usr/bin/ruby193 gem install bundler --no-ri --no-rdoc',
}
