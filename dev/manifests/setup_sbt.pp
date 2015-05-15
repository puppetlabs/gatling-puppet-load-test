exec { 'install_sbt_repo':
  # Command from the sbt getting started page
  command => 'curl https://bintray.com/sbt/rpm/rpm | tee /etc/yum.repos.d/bintray-sbt-rpm.repo',
  path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
}

package { 'sbt':
  ensure  => installed,
  require => Exec["install_sbt_repo"],
}
