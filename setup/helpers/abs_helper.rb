require 'net/http'
require 'timeout'
require 'json'
require 'yaml'

module AbsHelper

  # TODO: replace when ready
  #ABS_BASE_URL = 'https://cinext-abs.delivery.puppetlabs.net/api/v2'
  ABS_BASE_URL = 'https://cinext-abs-test.delivery.puppetlabs.net/api/v2'

  ABS_AWS_PLATFORM = 'el-7-x86_64'
  ABS_AWS_IMAGE_ID = 'ami-1b17242b'
  ABS_AWS_SIZE = 'c4.2xlarge'
  ABS_AWS_MOM_SIZE = 'c4.2xlarge'
  ABS_AWS_METRICS_SIZE = 'c4.2xlarge'
  ABS_AWS_REGION = 'us-west-2'

  # Allows us to switch between AWS and VMPooler by selecting different ABS os's
  # centos-7-x86-64-west is an AWS image, centos-7-x86_64 is vmpooler
  ABS_BEAKER_TYPE = 'centos-7-x86-64-west'
  ABS_BEAKER_ENGINE = 'aws'

  # TODO: replace when ready
  # ABS_AWS_REAP_TIME = '86400'
  ABS_AWS_REAP_TIME = '1200'

  def abs_initialize
    @abs_base_url = ENV['ABS_BASE_URL'] ? ENV['ABS_BASE_URL'] : ABS_BASE_URL
    @abs_aws_platform = ENV['ABS_AWS_PLATFORM'] ? ENV['ABS_AWS_PLATFORM'] : ABS_AWS_PLATFORM
    @abs_aws_image_id = ENV['ABS_AWS_IMAGE_ID'] ? ENV['ABS_AWS_IMAGE_ID'] : ABS_AWS_IMAGE_ID
    @abs_aws_size = ENV['ABS_AWS_SIZE'] ? ENV['ABS_AWS_SIZE'] : ABS_AWS_SIZE
    @abs_aws_region = ENV['ABS_AWS_REGION'] ? ENV['ABS_AWS_REGION'] : ABS_AWS_REGION
    @abs_aws_reap_time = ENV['ABS_AWS_REAP_TIME'] ? ENV['ABS_AWS_REAP_TIME'] : ABS_AWS_REAP_TIME
    @abs_aws_mom_size = ENV['ABS_AWS_MOM_SIZE'] ? ENV['ABS_AWS_MOM_SIZE'] : ABS_AWS_MOM_SIZE
    @abs_aws_metrics_size = ENV['ABS_AWS_METRICS_SIZE'] ? ENV['ABS_AWS_METRICS_SIZE'] : ABS_AWS_METRICS_SIZE
    @abs_beaker_pe_version = ENV['BEAKER_PE_VER'] ? ENV['BEAKER_PE_VER'] : nil
  end

  def abs_get_aws_tags(role)
    # TODO: handle more tags
    tags = {'role': role}
    if @abs_beaker_pe_version
      tags.merge!('pe_version': @abs_beaker_pe_version)
    end
    tags
  end

  def abs_get_awsdirect_request_body(role, size = @abs_aws_size)
    {'platform': @abs_aws_platform,
     'image_id': @abs_aws_image_id,
     'size': size,
     'region': @abs_aws_region,
     'reap_time': @abs_aws_reap_time,
     'tags': abs_get_aws_tags(role)}.to_json
  end

  def abs_get_awsdirectreturn_request_body(hostname)
    {"hostname": hostname}.to_json
  end

  def abs_get_token_from_fog_file
    home = ENV['HOME']
    fog_path = "#{home}/.fog"
    token = nil

    if File.exist?(fog_path)
      fog = YAML.load(File.read(fog_path))
      token = fog[:default][:abs_token]
      if !token
        puts "ABS token not found in .fog file at #{fog_path}"
      end
    else
      puts ".fog file not found in home directory: #{fog_path}"
    end
    token
  end

  def abs_get_token
    ENV['ABS_TOKEN'] ? token = ENV['ABS_TOKEN'] : token = abs_get_token_from_fog_file
    if token.nil?
      puts 'An ABS token must be set in either the ABS_TOKEN environment variable or the abs_token parameter in the .fog file'
    end
    token
  end

  def abs_get_request_post(uri)
    req = nil
    abs_token = abs_get_token
    if abs_token
      req =  Net::HTTP::Post.new(uri, {'Content-Type' => 'application/json', 'X-Auth-Token' => abs_token})
    else
      puts 'Unable to prepare a valid ABS request without a valid token'
    end
    req
  end

  # TODO: rename?
  def abs_request_awsdirect(uri, body)
    res = nil
    req = abs_get_request_post(uri)

    if req
      req.body = body
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 120

      puts
      puts 'sending request body:'
      puts body
      puts "to uri: #{uri}"
      puts

      res = http.request(req)
      puts "response code: #{res.code}" unless res.nil?
      puts "response body: #{res.body}" unless res.nil?
      puts
    else
      puts 'Unable to complete the specified ABS request'
    end

    res
  end

  def abs_is_valid_response?(res, valid_response_codes = ['200'], invalid_response_bodies = ['', nil])
    # TODO: other criteria?
    is_valid_response = false

    if res.nil? || !valid_response_codes.include?(res.code) || invalid_response_bodies.include?(res.body)
      puts 'Invalid ABS response: '
      puts "code: #{res.code}" unless res.nil?
      puts "body: #{res.body}" unless res.nil?
    else
      is_valid_response = true
    end
    is_valid_response
  end

  def abs_get_a2a_hosts
    abs_initialize
    {'mom': @abs_aws_mom_size, 'metrics': @abs_aws_metrics_size}
  end

  def abs_reformat_resource_host(response_body)
    reformatted_json = nil

    begin
      json = JSON.parse(response_body)
      hostname = json['hostname']

      new_response_body = {
          'hostname': hostname,
          'type':     ABS_BEAKER_TYPE,
          'engine':   ABS_BEAKER_ENGINE}

      reformatted_json = new_response_body.to_json
    rescue
      puts 'JSON::ParserError encountered'
    end

    reformatted_json
  end

  def abs_update_last_abs_resource_hosts(abs_resource_hosts)
    File.write('last_abs_resource_hosts.log', abs_resource_hosts)
  end

  # hosts will likely come from abs_get_a2a_hosts:
  #  {'mom': @abs_aws_mom_size, 'metrics': @abs_aws_metrics_size}
  #
  # otherwise specify hosts in the following format
  #  {'role1': 'size1', 'role2': 'size2', ... }
  def abs_get_resource_hosts(hosts_to_request)
    abs_initialize

    uri = URI("#{@abs_base_url}/awsdirect")
    responses = []
    abs_resource_hosts = nil
    invalid_response = false

    hosts_to_request.each do |role, size|
      request_body = abs_get_awsdirect_request_body(role, size)
      response = abs_request_awsdirect(uri, request_body)

      # if any invalid responses are encountered stop and return any provisioned hosts
      if !abs_is_valid_response?(response)
        invalid_response = true
        puts "Unable to provision host for role: #{role}"

        # TODO: extract and test managing the responses
        if !responses.empty?
          puts 'Returning any provisioned hosts'
          abs_return_resource_hosts(responses.to_json)
        end

        # stop requesting hosts
        break

      else
        # reformat to satisfy beaker
        responses << JSON.parse(abs_reformat_resource_host(response.body))
      end

    end

    if responses.empty?
      puts 'No ABS hosts were provisioned'
      puts ''
    elsif !invalid_response
      abs_resource_hosts = responses.to_json
      ENV['ABS_RESOURCE_HOSTS'] = abs_resource_hosts
      puts "ABS_RESOURCE_HOSTS=#{ENV['ABS_RESOURCE_HOSTS']}"

      # write to 'last_abs_resource_hosts.log' (used when returning hosts)
      abs_update_last_abs_resource_hosts(abs_resource_hosts)

    end
    abs_resource_hosts
  end

  def abs_get_last_abs_resource_hosts
    file = 'last_abs_resource_hosts.log'
    last_abs_resource_hosts = nil
    expected = '[{"hostname":'

    if File.exist?(file)
      contents = File.read(file)
      if contents.start_with?(expected)
        last_abs_resource_hosts = contents
      else
        puts contents
        puts "Invalid last ABS resource hosts file: #{file}"
      end
    else
      puts "Last ABS resource hosts file not found: #{file}"
    end
    last_abs_resource_hosts
  end

  def abs_return_resource_hosts(abs_resource_hosts)
    abs_success_message = 'OK'
    abs_error_message = 'Could not return specified host with error'
    returned_hosts = nil
    puts "ABS hosts specified for return: #{abs_resource_hosts}"

    abs_initialize
    uri = URI("#{@abs_base_url}/awsdirectreturn")

    # TODO: verify abs_resource_hosts format?
    if !abs_resource_hosts
      puts 'De-provisioning via return_abs_resource_hosts requires an array of hostnames to be specified via the ABS_RESOURCE_HOSTS environment variable or the last_abs_resource_hosts.log file'
    else
      # returned_hosts = []
      hosts = JSON.parse(abs_resource_hosts)
      hosts.each do |host|
        hostname = host['hostname']

        puts "Returning host: #{hostname}"
        body = abs_get_awsdirectreturn_request_body(hostname)
        res = abs_request_awsdirect(uri, body)

        if abs_is_valid_response?(res)
          puts "Successfully returned host: #{hostname}"
          returned_hosts ? returned_hosts << host : returned_hosts = [host]
        else
          puts "Failed to return host: #{hostname}"
        end

      end
    end
    returned_hosts ? returned_hosts.to_json : returned_hosts
  end

end