FROM centos:7

RUN yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum -y install java-1.8.0-openjdk java-1.8.0-openjdk-devel xauth
RUN rpm -ivh http://dl.bintray.com/sbt/rpm/sbt-0.13.7.rpm
RUN mkdir -p /usr/share/sbt/conf/
RUN echo '-mem 3072' >> /usr/share/sbt/conf/sbtopts
RUN mkdir /root/gatling-puppet-load-test
#do the first run which downloads stuff.
RUN sbt run ; exit 0
WORKDIR /root/gatling-puppet-load-test
