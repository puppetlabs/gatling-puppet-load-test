require "json"

rake_cmd='RAILS_ENV=production /opt/puppet/bin/rake -f /opt/puppet/share/puppet-dashboard/Rakefile'
test_name = "Setup for Gatling Performance Run"

authconf = %q{path /
auth any
allow *
}

# create custom auth.conf
on master, "mv /etc/puppetlabs/puppet/auth.conf /etc/puppetlabs/puppet/auth.conf.bak"
create_remote_file(master, '/etc/puppetlabs/puppet/auth.conf', authconf)
on master, "chown root:pe-puppet /etc/puppetlabs/puppet/auth.conf && chmod 640 /etc/puppetlabs/puppet/auth.conf"

json  = File.read('suite/nodes.json')
nodedata = JSON.parse(json)

# Add nodenames
nodedata["nodes"].each_key {|node| 
  on master, "#{rake_cmd} node:add name=#{node}"
}

# Install modules and class per node
nodedata["nodes"].each_key {|node| 
  nodedata["nodes"]["#{node}"].each_key { |key|
    if key == "modules" then
      nodedata["nodes"]["#{node}"]["#{key}"].each { |m|
        on master, "puppet module install #{m}"
      }
    elsif key == "classes" then
      nodedata["nodes"]["#{node}"]["#{key}"].each { |c|
        on master, "#{rake_cmd} nodeclass:add name=#{c}"
      }
    end
  }
}

# register nodes and classes
nodedata["nodes"].each_key {|node| 
  nodedata["nodes"]["#{node}"].each_key { |key|
    if key == "classes" then
      nodedata["nodes"]["#{node}"]["#{key}"].each { |c|
        on master, "#{rake_cmd} node:classes name=#{node} classes=#{c}"
      }
    end
  }
}
