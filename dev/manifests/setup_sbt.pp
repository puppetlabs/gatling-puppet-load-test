# See http://www.scala-sbt.org/0.13/docs/Installing-sbt-on-Linux.html
# for instructions on how to install manually for Ubuntu/Deb, RHEL/RPM, etc

# TODO Replace repo+package installation with direct tarball download using
# the camptocamp/archive module to avoid a bunch of dependencies that comes
# with the package

yumrepo { 'bintray-sbt-rpm':
  baseurl  => 'http://dl.bintray.com/sbt/rpm',
  enabled  => 1,
  gpgcheck => 0,
}
->
package { 'sbt':
  ensure  => installed,
}
->
package { 'nss':
  # This is necessary for 'sbt' to run under java 1.7, which
  # is what is currently pulled in by the rtyler/jenkins module
  ensure => latest,
}
