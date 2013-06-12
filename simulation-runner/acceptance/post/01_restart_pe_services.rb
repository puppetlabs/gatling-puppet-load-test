test_name = "Restart PE services"

#on master, "/etc/init.d/pe-httpd restart && /etc/init.d/pe-puppet-dashboard-workers restart"
on master, "/etc/init.d/pe-httpd restart && service pe-puppet-dashboard-workers restart"
on master, "/etc/init.d/pe-mcollective restart && /etc/init.d/pe-activemq restart"
on master, "/etc/init.d/pe-memcached restart"
on master, "/etc/init.d/pe-puppet restart"
