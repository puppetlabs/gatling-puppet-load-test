require 'beaker-pe-large-environments'

test_name 'install PE for a scale environment' do
  if !is_pre_aio_version?
    # Must include the dashboard so that split installs add these answers to classification
    r10k_remote = '/opt/puppetlabs/server/data/puppetserver/r10k/control-repo'

    if use_meep?(master['pe_ver'] || options['pe_ver'])
      @options[:answers] ||= {}
      @options[:answers]['puppet_enterprise::profile::master::r10k_remote'] = r10k_remote
    else
      [master, compile_masters, dashboard].flatten.uniq.each do |host|
        host[:custom_answers] = {
          :q_puppetmaster_r10k_remote      => r10k_remote,
        }
      end

      pe_version = (master['pe_ver'] || options[:pe_ver])
      if version_is_less(pe_version, '2016.2')
        # If installing an older version of PE,
        # lay down a custom hiera config that increases
        # the code manager deploy timeout to the newest default
        hiera_additions = <<-HIERA_ADDNS
puppet_enterprise::master::code_manager::timeouts_deploy: 600
        HIERA_ADDNS
        pre_config_hiera(master, hiera_additions)
        master['hieradata_dir_used_in_install'] = '/etc/puppetlabs/code/environments/production/hieradata'
      end
    end
  end

  step 'install PE' do
    install_lei
  end
end
