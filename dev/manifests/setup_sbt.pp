yumrepo { "sbt yum repo":
  baseurl => "https://dl.bintray.com/sbt/rpm",
  enabled => true,
  gpgcheck => 0,
}

package { 'sbt':
  ensure => installed,
  require => Yumrepo["sbt yum repo"],
}
