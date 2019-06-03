# frozen_string_literal: true

require "scooter"
include Scooter::HttpDispatchers # rubocop:disable Style/MixinUsage

def dispatcher
  @dispatcher ||= ConsoleDispatcher.new(dashboard)
end

def update_classifier_classes
  # Clear the environment cache in puppet server because the update-classes
  # endpoint no longer handles this in the node classifier (PE-11042)
  unless file_sync_helper.file_sync_services_enabled?
    ssl_dir = "/etc/puppetlabs/puppet/ssl"
    master_certname = master.node_name
    curl_url = "https://#{master}:8140/puppet-admin-api/v1/environment-cache"
    curl_flags = [
      "-X DELETE",
      "-I",
      "--key #{ssl_dir}/private_keys/#{master_certname}.pem",
      "--cert #{ssl_dir}/certs/#{master_certname}.pem",
      "--cacert #{ssl_dir}/certs/ca.pem"
    ]

    curl_on(master, "#{curl_url} #{curl_flags.join(' ')}")
  end
  dispatcher.update_classes
end

def pe_infra_uuid
  unless @pe_infra_uuid
    pe_infra_group = dispatcher.get_node_group_by_name("PE Infrastructure")
    raise "No node group named PE Infrastructure found" unless pe_infra_group

    @pe_infra_uuid = pe_infra_group["id"]
  end
  @pe_infra_uuid
end
