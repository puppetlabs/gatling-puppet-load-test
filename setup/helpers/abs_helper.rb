require "net/http"
require "net/ssh"
require "net/ssh/errors"
require "timeout"
require "json"
require "yaml"
require "in_parallel"

include InParallel

# Provides functionality to provision and deprovision hosts via ABS
module AbsHelper
  ABS_BASE_URL = "https://cinext-abs.delivery.puppetlabs.net/api/v2".freeze
  AWS_PLATFORM = "centos-7-x86_64".freeze
  AWS_IMAGE_ID = "ami-a042f4d8".freeze
  AWS_VOLUME_SIZE = "80".freeze
  AWS_REGION = "us-west-2".freeze

  # Allows us to switch between AWS and VMPooler by selecting a different ABS OS
  # centos-7-x86-64-west is an AWS image, centos-7-x86_64 is vmpooler
  ABS_BEAKER_ENGINE = "aws".freeze

  # TODO: is this the value we want to use?
  AWS_REAP_TIME = "86400".freeze

  # TODO: update mom and metrics config
  MOM_VOLUME_SIZE = AWS_VOLUME_SIZE.freeze
  METRICS_VOLUME_SIZE = AWS_VOLUME_SIZE.freeze

  # Checks whether the user has a valid token and if so initializes the instance variables
  #
  # @author Bill Claytor
  #
  # @return [true,false] Based on whether the user has a valid token
  #
  # @example
  #   success = abs_initialize
  #
  def abs_initialize
    # only proceed if the user has a token
    user_has_token = false
    if get_abs_token
      user_has_token = true

      @abs_base_url = ENV["ABS_BASE_URL"] ? ENV["ABS_BASE_URL"] : ABS_BASE_URL
      @aws_platform = ENV["ABS_AWS_PLATFORM"] ? ENV["ABS_AWS_PLATFORM"] : AWS_PLATFORM
      @aws_image_id = ENV["ABS_AWS_IMAGE_ID"] ? ENV["ABS_AWS_IMAGE_ID"] : AWS_IMAGE_ID
      @aws_region = ENV["ABS_AWS_REGION"] ? ENV["ABS_AWS_REGION"] : AWS_REGION
      @aws_reap_time = ENV["ABS_AWS_REAP_TIME"] ? ENV["ABS_AWS_REAP_TIME"] : AWS_REAP_TIME
      @mom_size = ENV["ABS_AWS_MOM_SIZE"]
      @mom_volume_size = ENV["ABS_AWS_MOM_VOLUME_SIZE"] ? ENV["ABS_AWS_MOM_VOLUME_SIZE"] : MOM_VOLUME_SIZE
      @metrics_size = ENV["ABS_AWS_METRICS_SIZE"]
      @metrics_volume_size = ENV["ABS_METRICS_VOLUME_SIZE"] ? ENV["ABS_METRICS_VOLUME_SIZE"] : METRICS_VOLUME_SIZE
      @abs_beaker_pe_version = ENV["BEAKER_PE_VER"] ? ENV["BEAKER_PE_VER"] : nil
    end
    user_has_token
  end

  # Initializes AbsHelper and returns the hosts for an ApplesToApples run
  #
  # @author Bill Claytor
  #
  # @return [Hash] The ApplesToApples hosts (mom and metrics)
  #
  # @example
  #   hosts = abs_get_a2a_hosts
  #
  def get_a2a_hosts
    abs_initialize
    mom =
      { 'role': "mom",
        'size': @mom_size,
        'volume_size': @mom_volume_size }

    metrics =
      { 'role': "metrics",
        'size': @metrics_size,
        'volume_size': @metrics_volume_size }

    hosts = [mom, metrics]

    return hosts
  end

  # Attempts to provision the specified hosts via ABS
  #
  # hosts will likely come from abs_get_a2a_hosts:
  #  {"mom": @abs_aws_mom_size, "metrics": @abs_aws_metrics_size}
  #
  # otherwise specify hosts in the following format
  #  {"role1": "size1", "role2": "size2", ... }
  #
  # @author Bill Claytor
  #
  # @param [Array] hosts_to_request The hosts to request via ABS
  #
  # @return [JSON, nil] The hosts that were provisioned via ABS, otherwise nil
  #
  # @example
  #   abs_resource_hosts = abs_get_resource_hosts(hosts_to_request)
  #
  def get_abs_resource_hosts(hosts_to_request)
    hosts = []
    abs_resource_hosts = nil

    # ensure the user has a token before proceeding
    raise "Unable to proceed without a valid ABS token" unless abs_initialize

    puts
    puts "Attempting to provision ABS hosts: #{hosts_to_request}"
    puts

    begin

      hosts_to_request.each do |host_to_request|
        hosts << get_abs_resource_host(host_to_request)
      end

    rescue => e

      puts "Error encountered: #{e.message}"
      puts

      if hosts.empty?
        puts "No ABS hosts were provisioned"
        puts
      else
        puts "Returning any provisioned hosts"
        return_abs_resource_hosts(hosts.to_json)
      end

      raise

    end

    if !hosts.empty?
      abs_resource_hosts = hosts.to_json
      ENV["ABS_RESOURCE_HOSTS"] = abs_resource_hosts
      puts "ABS_RESOURCE_HOSTS=#{ENV['ABS_RESOURCE_HOSTS']}"

      # write to "last_abs_resource_hosts.log" (used when returning hosts)
      update_last_abs_resource_hosts(abs_resource_hosts)
    end

    # only return the hosts if they're successfully verified
    success = verify_abs_hosts(hosts) unless abs_resource_hosts.nil?
    verified_hosts = success ? abs_resource_hosts : nil

    if verified_hosts
      puts
      puts "ABS hosts have been successfully provisioned"
    end

    return verified_hosts

  end

  # Attempts to provision the specified host via ABS
  #
  # @author Bill Claytor
  #
  # @param [Hash] host_to_request The host to request via ABS
  #
  # @return [Hash, nil] The host provisioned via ABS, otherwise nil
  #
  # @example
  #   abs_resource_host = abs_get_resource_host(host_to_request)
  #
  def get_abs_resource_host(host_to_request)
    uri = URI("#{@abs_base_url}/awsdirect")
    puts "Host_to_request: #{host_to_request}"

    request_body = get_awsdirect_request_body(host_to_request)
    response = perform_awsdirect_request(uri, request_body)

    if !valid_abs_response?(response)
      raise "Unable to provision host for role: #{host_to_request[:role]}"
    else
      host = parse_awsdirect_response_body(response.body)
    end

    return host

  end

  # Returns the specified ABS hosts via ABS
  #
  # @author Bill Claytor
  #
  # @param [JSON] abs_resource_hosts The hosts to de-provision
  #
  # @return [JSON] The hosts that were successfully returned
  #
  # @example
  #   returned_hosts = abs_return_resource_hosts(abs_resource_hosts)
  #
  def return_abs_resource_hosts(abs_resource_hosts)
    returned_hosts = []
    puts "ABS hosts specified for return: #{abs_resource_hosts}"

    is_valid = valid_abs_resource_hosts?(abs_resource_hosts)
    unless is_valid
      puts "De-provisioning via awsdirectreturn requires an array of hostnames to be specified"
      puts "Specify hostnames via the ABS_RESOURCE_HOSTS environment variable"
      puts "Or specify via the last_abs_resource_hosts.log file"
      puts
    end

    has_token = abs_initialize
    unless has_token
      puts "Unable to proceed without a valid ABS token"
      puts
    end

    if is_valid && has_token
      uri = URI("#{@abs_base_url}/awsdirectreturn")
      hosts = JSON.parse(abs_resource_hosts)
      hosts.each do |host|
        hostname = host["hostname"]

        puts "Returning host: #{hostname}"
        body = get_awsdirectreturn_request_body(hostname)
        res = perform_awsdirect_request(uri, body)

        if valid_abs_response?(res)
          puts "Successfully returned host: #{hostname}"
          returned_hosts << host
        else
          puts "Failed to return host: #{hostname}"
        end
      end

    end

    returned_hosts.to_json
  end

  # Reads the ABS hosts from the last_abs_resource_hosts.log file
  #
  # @author Bill Claytor
  #
  # @return [JSON, nil] The hosts of the log file if successful, otherwise nil
  #
  # @example
  #   abs_resource_hosts = abs_get_last_abs_resource_hosts
  #
  def get_last_abs_resource_hosts
    file = "last_abs_resource_hosts.log"
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

  # Creates the tags hash with the specified role
  #
  # @author Bill Claytor
  #
  # @param [string] role The role for the host being requested
  #
  # @return [Hash] The tags for the host being requested
  #
  # @example
  #   tags = abs_get_aws_tags("metrics")
  #
  def get_aws_tags(role)
    # TODO: handle more tags
    tags = { "role": role }
    tags[:pe_version] = @abs_beaker_pe_version if @abs_beaker_pe_version
    tags
  end

  # Creates the awsdirect request body for the specified role
  #
  # @author Bill Claytor
  #
  # @param [Hash] host_to_request The host being requested
  #
  # @return [JSON] The JSON request body for the host being requested
  #
  # @example
  #   req_body = abs_get_awsdirect_request_body("metrics", "c4.2xlarge", "80")
  #
  def get_awsdirect_request_body(host_to_request)
    role = host_to_request[:role]
    size = host_to_request[:size]
    volume_size = host_to_request[:volume_size]

    request_body = { "platform": @aws_platform,
      "image_id": @aws_image_id,
      "size": size,
      "region": @aws_region,
      "reap_time": @aws_reap_time,
      "tags": get_aws_tags(role),
      "volume_size": volume_size }.to_json

    return request_body
  end

  # Creates the awsdirectreturn request body for the specified host
  #
  # @author Bill Claytor
  #
  # @param [string] hostname The host being returned
  #
  # @return [JSON] The JSON request body for the host being returned
  #
  # @example
  #   req_body = abs_get_awsdirectreturn_request_body("myhost")
  #
  def get_awsdirectreturn_request_body(hostname)
    { "hostname": hostname }.to_json
  end

  # Attempts to retrieve the ABS token from the user's .fog file
  #
  # @author Bill Claytor
  #
  # @return [string, nil] The user's token or nil if not found
  #
  # @example
  #   token = abs_get_token_from_fog_file
  #
  # rubocop:disable Security/YAMLLoad
  def get_abs_token_from_fog_file
    home = ENV["HOME"]
    fog_path = "#{home}/.fog"
    token = nil

    if File.exist?(fog_path)
      file = File.read(fog_path)

      begin
        # TODO: safe_load?
        fog = YAML.load(file)
      rescue
        # TODO: raise?
        puts "YAML error encountered parsing .fog file"
      end

      token = fog[:default][:abs_token]
      puts "ABS token not found in .fog file at #{fog_path}" unless token
    else
      puts ".fog file not found in home directory: #{fog_path}"
    end
    token
  end

  # rubocop:enable Security/YAMLLoad

  # Attempts to retrieve the ABS token from the ABS_TOKEN environment variable
  # or the user's .fog file
  #
  # Sets the ABS_TOKEN environment variable to the token if provided via the .fog file
  #
  # @author Bill Claytor
  #
  # @return [string, nil] The user's token or nil if not found
  #
  # @example
  #   token = def abs_get_token
  #
  def get_abs_token
    token = ENV["ABS_TOKEN"] ? ENV["ABS_TOKEN"] : get_abs_token_from_fog_file
    if token.nil?
      puts "An ABS token must be set in either the ABS_TOKEN environment variable"
      + " or the abs_token parameter in the .fog file"
    end
    ENV["ABS_TOKEN"] = token
    token
  end

  # Creates the request to be sent based on the specified URI
  #
  # @author Bill Claytor
  #
  # @param [URI] uri The URI where the request should be sent
  #
  # @return [Net::HTTP::Post, nil] The request or nil if unsuccessful
  #
  # @example
  #   request = abs_get_request_post(uri)
  #
  def get_abs_post_request(uri)
    req = nil
    abs_token = get_abs_token
    if abs_token
      req = Net::HTTP::Post.new(uri, "Content-Type" => "application/json",
                                     "X-Auth-Token" => abs_token)
    else
      puts "Unable to prepare a valid ABS request without a valid token"
    end
    req
  end

  # Prepares and submits the awsdirect request with the specified URI and body
  #
  # @author Bill Claytor
  #
  # @param [URI] uri The URI where the request should be sent
  # @param [JSON] body The request body
  #
  # @return [Net::HTTPResponse, nil] The HTTP response or nil if unsuccessful
  #
  # @example
  #   response = abs_request_awsdirect(uri, body)
  #
  def perform_awsdirect_request(uri, body)
    res = nil
    req = get_abs_post_request(uri)

    if req
      req.body = body
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = 120

      puts "sending request body:"
      puts body
      puts "to uri: #{uri}"
      puts

      res = http.request(req)
      puts "response code: #{res.code}" unless res.nil?
      puts "response body: #{res.body}" unless res.nil?
      puts
    else
      puts "Unable to complete the specified ABS request"
    end

    res
  end

  # Determines whether the ABS response is valid
  #
  # @author Bill Claytor
  #
  # @param [Net::HTTPResponse] res The HTTP response to evaluate
  # @param [Array] valid_response_codes The list of valid response codes
  # @param [Array] invalid_response_bodies The list of invalid response bodies
  #
  # @return [true,false] Based on whether the response is valid
  #
  # @example
  #   valid = abs_valid_response?(res, ["200"], ["", nil])
  #
  def valid_abs_response?(res, valid_response_codes = ["200"],
                          invalid_response_bodies = ["", nil])
    # TODO: other criteria?
    is_valid_response = false

    if res.nil? || !valid_response_codes.include?(res.code) ||
       invalid_response_bodies.include?(res.body)
      puts "Invalid ABS response: "
      puts "code: #{res.code}" unless res.nil?
      puts "body: #{res.body}" unless res.nil?
      puts
    else
      is_valid_response = true
    end
    is_valid_response
  end

  # Parses the awsdirect response body
  #
  # Note: Beaker requires hosts to be specified in this format
  #
  # @author Bill Claytor
  #
  # @param [JSON] response_body The response body for the provisioned host
  #
  # @return [Hash] The ABS host
  #
  # @example
  #   host = parse_awsdirect_response_body(response_body)
  #
  def parse_awsdirect_response_body(response_body)
    host = JSON.parse(response_body)
    hostname = host["hostname"]
    type = host["type"]

    abs_resource_host = {
        'hostname': hostname,
        'type':     type,
        'engine':   ABS_BEAKER_ENGINE
    }

    return abs_resource_host
  end

  # Writes the current ABS resource hosts to the log file
  # last_abs_resource_hosts.log
  #
  # @author Bill Claytor
  #
  # @param [JSON] abs_resource_hosts The current ABS resource hosts
  #
  # @return [void]
  #
  # @example
  #   abs_update_last_abs_resource_hosts(abs_resource_hosts)
  #
  def update_last_abs_resource_hosts(abs_resource_hosts)
    File.write("last_abs_resource_hosts.log", abs_resource_hosts)
  end

  # Calculates and waits a back-off period based on the number of tries
  # Logs each backupoff time and retry value to the console
  #
  # This is duplicated code from beaker-aws:
  # https://github.com/puppetlabs/beaker-aws/blob/master/lib/beaker/hypervisor/aws_sdk.rb#L682-L695
  #
  # @param tries [Number] number of tries to calculate back-off period
  #
  # @return [void]
  #
  # @example
  #   abs_backoff_sleep(tries)
  #
  def backoff_sleep(tries)
    # Exponential with some randomization
    sleep_time = 2**tries
    puts "Sleeping for #{sleep_time} seconds after attempt #{tries}..."
    sleep sleep_time
    nil
  end

  # Verifies that the specified host can be accessed via ssh as the root user
  #
  # @author Bill Claytor
  #
  # @param [string] host The host to verify
  #
  # @return [true, false] Based on successful verification of the specified host
  #
  # @example
  #   success = abs_verify_host(host)
  #
  def verify_abs_host(host)
    result = nil
    success = false
    user = "root"
    key_file = ENV['BEAKER_KEYFILE'] ? ENV['BEAKER_KEYFILE'] : "#{ENV['HOME']}/.ssh/id_rsa-acceptance"

    puts "Verifying #{host}"
    puts

    # TODO: 8 tries?
    for tries in 1..8

      puts "Attempt #{tries} for #{host}"

      begin
        # verify that Beaker will be able to start using the host
        ssh = Net::SSH.start(host, user, keys: key_file)
        result = ssh.exec!("rpm -q curl")
        ssh.close

        if result
          puts "Result: #{result}"
          raise "Error: root account is not yet configured" if result.to_s.include?("centos")
          success = true
          break

        else
          raise "Unknown error"
        end

      rescue Net::SSH::HostKeyMismatch => err
        err.remember_host!
      rescue => err
        puts "Attempted connection to #{host} failed with '#{err}'"
        backoff_sleep(tries)

      end

    end

    puts "Failed to verify host #{host}" unless success
    return success
  end

  # Verifies that the specified hosts can be accessed via ssh as the root user
  #
  # @author Bill Claytor
  #
  # @param [Array] hosts The hosts to verify
  #
  # @return [true, false] Based on successful verification of the specified hosts
  #
  # @example
  #   success = abs_verify_hosts(host)
  #
  def verify_abs_hosts(hosts)
    success = false
    puts "Verifying ABS hosts: #{hosts}"
    hosts.each do |host|
      puts
      puts "Current host: #{host}"

      success = verify_abs_host(host[:hostname])
      break unless success
    end

    puts "Unable to verify the provisioned hosts" unless success
    return success
  end

  # Determines whether the specified hosts list is valid
  #
  # @author Bill Claytor
  #
  # @param [JSON] abs_resource_hosts The hosts to validate
  #
  # @return [true, false] Based on the validity of the specified hosts
  #
  # @example
  #   valid = abs_valid_resource_hosts?(abs_resource_hosts)
  #
  def valid_abs_resource_hosts?(abs_resource_hosts)
    is_valid = false

    if abs_resource_hosts.nil?
      puts "A valid hosts array is required; nil was specified"
      puts
    else

      begin
        hosts = JSON.parse(abs_resource_hosts)
        host = hosts[0]
        hostname = host["hostname"]
        if !hostname.nil? && !hostname.empty?
          is_valid = true
        else
          puts "The specified resource host array is not valid: #{abs_resource_hosts}"
          puts
        end
      rescue
        # TODO: raise?
        puts "JSON::ParserError encountered parsing the hosts array: #{abs_resource_hosts}"
      end

    end

    is_valid
  end
end
