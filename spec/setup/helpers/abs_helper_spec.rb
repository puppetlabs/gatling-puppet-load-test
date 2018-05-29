require './setup/helpers/abs_helper'

class AbsHelperClass
  include AbsHelper
end

describe AbsHelperClass do
  let(:test_net_http) { Class.new }
  let(:test_net_http_instance) { Class.new }
  let(:test_net_http_post) { Class.new }
  let(:test_http_request) { Class.new }
  let(:test_http_response) { Class.new }

  TEST_ABS_TOKEN = 'test_abs_token_zzz'
  TEST_ABS_BASE_URL = 'https://testing.puppet.net/v2'
  TEST_ABS_AWS_PLATFORM = 'test-amazon-6-x86_64'
  TEST_ABS_AWS_IMAGE_ID = 'test-ami-a07379d9'
  TEST_ABS_AWS_SIZE = 'test.c3.large'
  TEST_ABS_AWS_REGION = 'test-us-west-2'
  TEST_ABS_AWS_REAP_TIME = '12345'
  TEST_ABS_AWS_MOM_SIZE = TEST_ABS_AWS_SIZE
  TEST_ABS_AWS_METRICS_SIZE = TEST_ABS_AWS_SIZE

  TEST_AWSDIRECT_URL = "#{TEST_ABS_BASE_URL}/awsdirect"
  TEST_AWSDIRECT_URI = URI(TEST_AWSDIRECT_URL)
  TEST_AWSDIRECTRETURN_URL = "#{TEST_ABS_BASE_URL}/awsdirectreturn"
  TEST_AWSDIRECTRETURN_URI = URI(TEST_AWSDIRECTRETURN_URL)

  TEST_HOSTNAME = 'testing.puppet.net'
  TEST_ABS_TYPE = 'el-7-x86_64'
  TEST_BEAKER_TYPE = 'centos-7-x86-64-west'
  TEST_ENGINE = 'aws'
  TEST_BEAKER_PE_VERSION = '2018.1.0-rc17'
  TEST_ROLE = 'test-role'

  TEST_EXPECTED_REQUEST_HEADERS = {'Content-Type' => 'application/json', 'X-Auth-Token' => TEST_ABS_TOKEN}

  TEST_AWSDIRECT_REQUEST_BODY =
  { 'platform': TEST_ABS_AWS_PLATFORM,
    'image_id': TEST_ABS_AWS_IMAGE_ID,
    'size': TEST_ABS_AWS_SIZE,
    'region': TEST_ABS_AWS_REGION,
    'reap_time': TEST_ABS_AWS_REAP_TIME,
    'tags':
        {'role': TEST_ROLE, 'pe_version': TEST_BEAKER_PE_VERSION}
  }.to_json

  TEST_AWSDIRECT_MOM_REQUEST_BODY =
      { 'platform': TEST_ABS_AWS_PLATFORM,
        'image_id': TEST_ABS_AWS_IMAGE_ID,
        'size': TEST_ABS_AWS_MOM_SIZE,
        'region': TEST_ABS_AWS_REGION,
        'reap_time': TEST_ABS_AWS_REAP_TIME,
        'tags':
            {'role': 'mom', 'pe_version': 'value2'}
      }.to_json

  TEST_AWSDIRECT_METRICS_REQUEST_BODY =
      { 'platform': TEST_ABS_AWS_PLATFORM,
        'image_id': TEST_ABS_AWS_IMAGE_ID,
        'size': TEST_ABS_AWS_METRICS_SIZE,
        'region': TEST_ABS_AWS_REGION,
        'reap_time': TEST_ABS_AWS_REAP_TIME,
        'tags':
            {'field1': 'value1', 'pe_version': 'value2'}
      }.to_json

  TEST_AWSDIRECT_RESPONSE_BODY =
    { 'hostname': TEST_HOSTNAME,
      'instance_id': 'i-0721e8f28c67a0axx',
      'type': TEST_ABS_TYPE}.to_json

  TEST_REFORMATTED_RESPONSE_BODY =
      { 'hostname': TEST_HOSTNAME,
        'type': TEST_BEAKER_TYPE,
        'engine': TEST_ENGINE}.to_json

  TEST_AWSDIRECTRETURN_REQUEST_BODY = {'hostname': TEST_HOSTNAME}.to_json

  TEST_VALID_RESPONSE_BODY = 'OK'
  TEST_INVALID_RESPONSE_BODY = ''
  TEST_VALID_RESPONSE_CODE = '200'
  TEST_INVALID_RESPONSE_CODE = '777'

  TEST_ABS_RESOURCE_HOSTS_SINGLE = [
      { 'hostname': TEST_HOSTNAME,
        'type': TEST_BEAKER_TYPE,
        'engine': TEST_ENGINE}].to_json

  TEST_ABS_RESOURCE_HOSTS = [
      { 'hostname': TEST_HOSTNAME,
        'type': TEST_BEAKER_TYPE,
        'engine': TEST_ENGINE},
      { 'hostname': TEST_HOSTNAME,
        'type': TEST_BEAKER_TYPE,
        'engine': TEST_ENGINE}].to_json

  TEST_A2A_HOSTS = {'mom': TEST_ABS_AWS_MOM_SIZE, 'metrics': TEST_ABS_AWS_METRICS_SIZE}

  before {
    ENV['BEAKER_PE_VER'] = TEST_BEAKER_PE_VERSION
    subject.instance_variable_set(:@abs_base_url, TEST_ABS_BASE_URL)
    subject.instance_variable_set(:@abs_beaker_pe_version, TEST_BEAKER_PE_VERSION)
  }

  describe '#abs_initialize' do

    context 'when environment variables are specified' do

      it 'sets the properties to the specified values' do

        ENV['ABS_BASE_URL'] = TEST_ABS_BASE_URL
        ENV['ABS_AWS_PLATFORM'] = TEST_ABS_AWS_PLATFORM
        ENV['ABS_AWS_IMAGE_ID'] = TEST_ABS_AWS_IMAGE_ID
        ENV['ABS_AWS_SIZE'] = TEST_ABS_AWS_SIZE
        ENV['ABS_AWS_REGION'] = TEST_ABS_AWS_REGION
        ENV['ABS_AWS_REAP_TIME'] = TEST_ABS_AWS_REAP_TIME
        ENV['ABS_AWS_MOM_SIZE'] = TEST_ABS_AWS_MOM_SIZE
        ENV['ABS_AWS_METRICS_SIZE'] = TEST_ABS_AWS_METRICS_SIZE
        ENV['BEAKER_PE_VER'] = TEST_BEAKER_PE_VERSION

        subject.abs_initialize
        expect(subject.instance_variable_get(:@abs_base_url)). to eq(TEST_ABS_BASE_URL)
        expect(subject.instance_variable_get(:@abs_aws_platform)). to eq(TEST_ABS_AWS_PLATFORM)
        expect(subject.instance_variable_get(:@abs_aws_image_id)). to eq(TEST_ABS_AWS_IMAGE_ID)
        expect(subject.instance_variable_get(:@abs_aws_size)). to eq(TEST_ABS_AWS_SIZE)
        expect(subject.instance_variable_get(:@abs_aws_region)). to eq(TEST_ABS_AWS_REGION)
        expect(subject.instance_variable_get(:@abs_aws_reap_time)). to eq(TEST_ABS_AWS_REAP_TIME)
        expect(subject.instance_variable_get(:@abs_aws_mom_size)). to eq(TEST_ABS_AWS_MOM_SIZE)
        expect(subject.instance_variable_get(:@abs_aws_metrics_size)). to eq(TEST_ABS_AWS_METRICS_SIZE)
        expect(subject.instance_variable_get(:@abs_beaker_pe_version)). to eq(TEST_BEAKER_PE_VERSION)

      end

    end

    context 'when environment variables are not specified' do

      it 'sets the properties to the default values' do
        pending 'resolve stubbed constant issue'

        ENV['ABS_BASE_URL'] = nil
        ENV['ABS_AWS_PLATFORM'] = nil
        ENV['ABS_AWS_IMAGE_ID'] = nil
        ENV['ABS_AWS_SIZE'] = nil
        ENV['ABS_AWS_REGION'] = nil
        ENV['ABS_AWS_REAP_TIME'] = nil
        ENV['ABS_AWS_MOM_SIZE'] = nil
        ENV['ABS_AWS_METRICS_SIZE'] = nil

        stub_const('ABS_BASE_URL', TEST_ABS_BASE_URL)
        stub_const('ABS_AWS_PLATFORM', TEST_ABS_AWS_PLATFORM)
        stub_const('ABS_AWS_IMAGE_ID', TEST_ABS_AWS_IMAGE_ID)
        stub_const('ABS_AWS_SIZE', TEST_ABS_AWS_SIZE)
        stub_const('ABS_AWS_MOM_SIZE', TEST_ABS_AWS_MOM_SIZE)
        stub_const('ABS_AWS_METRICS_SIZE', TEST_ABS_AWS_METRICS_SIZE)
        stub_const('ABS_AWS_REGION', TEST_ABS_AWS_REGION)
        stub_const('ABS_AWS_REAP_TIME', TEST_ABS_AWS_REAP_TIME)

        # TODO: stubbed constants aren't used by the properties in the code under test
        # subject.abs_initialize

        expect(subject.instance_variable_get(:@abs_base_url)). to eq(TEST_ABS_BASE_URL)
        expect(subject.instance_variable_get(:@abs_aws_platform)). to eq(TEST_ABS_AWS_PLATFORM)
        expect(subject.instance_variable_get(:@abs_aws_image_id)). to eq(TEST_ABS_AWS_IMAGE_ID)
        expect(subject.instance_variable_get(:@abs_aws_size)). to eq(TEST_ABS_AWS_SIZE)
        expect(subject.instance_variable_get(:@abs_aws_region)). to eq(TEST_ABS_AWS_REGION)
        expect(subject.instance_variable_get(:@abs_aws_reap_time)). to eq(TEST_ABS_AWS_REAP_TIME)
        expect(subject.instance_variable_get(:@abs_aws_mom_size)). to eq(TEST_ABS_AWS_MOM_SIZE)
        expect(subject.instance_variable_get(:@abs_aws_metrics_size)). to eq(TEST_ABS_AWS_METRICS_SIZE)

        subject.abs_initialize
      end

    end

  end

  describe '#abs_get_aws_tags' do

    context 'when a pe version is specified' do

      it 'returns tags including the specified role and pe version' do
        test_expected_tags = {'role': TEST_ROLE, 'pe_version': TEST_BEAKER_PE_VERSION}

        subject.instance_variable_set(:@abs_beaker_pe_version, TEST_BEAKER_PE_VERSION)
        expect(subject.abs_get_aws_tags(TEST_ROLE)). to eq(test_expected_tags)
      end

    end

    context 'when a pe version is not specified' do

      it 'returns tags that include only the specified role' do
        test_expected_tags = {'role': TEST_ROLE}

        subject.instance_variable_set(:@abs_beaker_pe_version, nil)
        expect(subject.abs_get_aws_tags(TEST_ROLE)). to eq(test_expected_tags)
      end

    end

  end

  describe '#abs_get_awsdirect_request_body' do

    before {
      subject.instance_variable_set("@abs_aws_size", TEST_ABS_AWS_SIZE)
      subject.instance_variable_set("@abs_aws_platform", TEST_ABS_AWS_PLATFORM)
      subject.instance_variable_set("@abs_aws_image_id", TEST_ABS_AWS_IMAGE_ID)
      subject.instance_variable_set("@abs_aws_region", TEST_ABS_AWS_REGION)
      subject.instance_variable_set("@abs_aws_reap_time", TEST_ABS_AWS_REAP_TIME)
    }

    context 'when a role is specified' do

      it 'uses the default size and returns the expected result' do
        test_expected_request_body = TEST_AWSDIRECT_REQUEST_BODY
        expect(subject.abs_get_awsdirect_request_body(TEST_ROLE)). to eq(test_expected_request_body)
      end

    end

    context 'when a role and size are specified' do

      it 'uses the specified size and returns the expected result' do
        test_role = 'new-role'
        test_size = 'new-size'

        test_expected_request_body =
            { 'platform': TEST_ABS_AWS_PLATFORM,
              'image_id': TEST_ABS_AWS_IMAGE_ID,
              'size': test_size,
              'region': TEST_ABS_AWS_REGION,
              'reap_time': TEST_ABS_AWS_REAP_TIME,
              'tags':
                  {'role': test_role, 'pe_version': TEST_BEAKER_PE_VERSION}
            }.to_json

        expect(subject.abs_get_awsdirect_request_body(test_role, test_size)). to eq(test_expected_request_body)
      end

    end

  end

  describe '#abs_get_awsdirectreturn_request_body' do

    context 'when a hostname is specified' do

      it 'returns the expected result' do
        test_expected_body = {'hostname': TEST_HOSTNAME}.to_json
        expect(subject.abs_get_awsdirectreturn_request_body(TEST_HOSTNAME)). to eq(test_expected_body)
      end

    end
  end

  describe '#abs_get_token_from_fog_file' do

    context 'when the .fog file exists' do

      context 'when the .fog file contains the abs token' do

        it 'returns the token' do
          fog_file =
              ":default:
              :abs_token: #{TEST_ABS_TOKEN}"

          expect(File).to receive(:exist?).and_return(true)
          expect(File).to receive(:read).and_return(fog_file)

          expect(subject.abs_get_token_from_fog_file).to eq(TEST_ABS_TOKEN)
        end

      end

      context 'when the .fog file does not contain the abs token' do

        it 'reports the error and returns nil' do
          fog_file =
              ':default:
              :not_abs_token: xyz123'

          expect(File).to receive(:exist?).and_return(true)
          expect(File).to receive(:read).and_return(fog_file)
          expect(subject).to receive(:puts).with(/ABS token not found/).at_least(:once)

          expect(subject.abs_get_token_from_fog_file).to eq(nil)
        end

      end

    end

    context 'when the .fog file does not exist' do

      it 'reports the error and returns nil' do
        expect(File).to receive(:exist?).and_return(false)
        expect(subject).to receive(:puts).with(/fog file not found/).at_least(:once)

        expect(subject.abs_get_token_from_fog_file).to eq(nil)
      end

    end

  end

  describe '#abs_get_token' do

    context 'when a token is set as an environment variable' do

      it 'returns the token' do
        ENV['ABS_TOKEN'] = TEST_ABS_TOKEN
        expect(subject.abs_get_token).to eq(TEST_ABS_TOKEN)
      end

    end

    context 'when a token is not set as an environment variable' do

      context 'when a token is set in the .fog file' do

        it 'returns the token' do
          ENV['ABS_TOKEN'] = nil
          expect(subject).to receive(:abs_get_token_from_fog_file).and_return(TEST_ABS_TOKEN)
          expect(subject.abs_get_token).to eq(TEST_ABS_TOKEN)
        end

      end

      context 'when a token is not set in the .fog file' do

        it 'reports the error and returns nil' do

          ENV['ABS_TOKEN'] = nil
          expect(subject).to receive(:abs_get_token_from_fog_file).and_return(nil)
          expect(subject).to receive(:puts).with(/An ABS token must be set/)
          expect(subject.abs_get_token).to eq(nil)
        end

      end

    end

  end

  describe '#abs_get_request_post' do

    context 'when an abs token is present' do

      it 'returns the expected result' do
        expect(subject).to receive(:abs_get_token).and_return(TEST_ABS_TOKEN)

        stub_const('Net::HTTP::Post', test_net_http_post)
        expect(test_net_http_post).to receive(:new).with(TEST_AWSDIRECT_URI, TEST_EXPECTED_REQUEST_HEADERS).and_return(test_http_request)

        expect(subject.abs_get_request_post(TEST_AWSDIRECT_URI)).to eq(test_http_request)
      end

    end

    context 'when an abs token is not present' do

      it 'reports the error and returns nil' do
        test_expected_message = 'Unable to prepare a valid ABS request without a valid token'
        test_expected_result = nil

        expect(subject).to receive(:abs_get_token).and_return(nil)
        expect(subject).to receive(:puts).with(test_expected_message)

        expect(subject.abs_get_request_post(TEST_AWSDIRECT_URI)).to eq(test_expected_result)
      end

    end

  end

  describe '#abs_request_awsdirect' do

    context 'when a request is successfully prepared' do

      it 'performs the request, reports and returns the response' do
        expect(subject).to receive(:abs_get_request_post).and_return(test_http_request)
        allow(test_http_request).to receive(:body=)

        stub_const('Net::HTTP', test_net_http)
        allow(test_net_http).to receive(:new).and_return(test_net_http_instance)

        allow(test_net_http_instance).to receive(:use_ssl=)
        allow(test_net_http_instance).to receive(:read_timeout=)
        expect(test_net_http_instance).to receive(:request).with(test_http_request).and_return(test_http_response)

        expect(test_http_response).to receive(:code).and_return(TEST_VALID_RESPONSE_CODE)
        expect(test_http_response).to receive(:body).and_return(TEST_VALID_RESPONSE_BODY)

        allow(subject).to receive(:puts)
        expect(subject).to receive(:puts).at_least(:once).with("response code: #{TEST_VALID_RESPONSE_CODE}")
        expect(subject).to receive(:puts).at_least(:once).with("response body: #{TEST_VALID_RESPONSE_BODY}")

        expect(subject.abs_request_awsdirect(TEST_AWSDIRECT_URI, TEST_AWSDIRECT_REQUEST_BODY)).to eq(test_http_response)

      end

    end

    context 'when a request is not successfully prepared' do

      it 'reports the error, does not attempt the request, and returns nil' do
        test_expected_message = 'Unable to complete the specified ABS request'
        test_expected_result = nil

        expect(subject).to receive(:abs_get_request_post).and_return(nil)
        expect(subject).to receive(:puts).with(test_expected_message)

        expect(subject.abs_request_awsdirect(TEST_AWSDIRECT_URI, TEST_AWSDIRECT_REQUEST_BODY)).to eq(test_expected_result)
      end

    end

  end

  describe '#abs_is_valid_response?' do

    context 'when a valid response is provided' do

      it 'returns true' do
        expect(test_http_response).to receive(:nil?).at_least(:once).and_return(false)
        expect(test_http_response).to receive(:code).at_least(:once).and_return(TEST_VALID_RESPONSE_CODE)
        expect(test_http_response).to receive(:body).at_least(:once).and_return(TEST_AWSDIRECT_RESPONSE_BODY)

        expect(subject.abs_is_valid_response?(test_http_response)).to eq(true)
      end

    end

    context 'when the response is nil' do

      it 'reports the error and returns false' do
        allow(subject).to receive(:puts)
        expect(subject).to receive(:puts).with(/Invalid ABS response/).at_least(:once)
        expect(subject.abs_is_valid_response?(nil)).to eq(false)
      end

    end

    context 'when the response code is not valid' do

      # TODO: Verify the full error message including values?

      it 'reports the error and returns false' do
        expect(test_http_response).to receive(:nil?).at_least(:once).and_return(false)
        expect(test_http_response).to receive(:code).at_least(:once).and_return(TEST_INVALID_RESPONSE_CODE)
        expect(test_http_response).to receive(:body).at_least(:once).and_return(TEST_AWSDIRECT_RESPONSE_BODY)

        allow(subject).to receive(:puts)
        expect(subject).to receive(:puts).with(/Invalid ABS response/)
        expect(subject).to receive(:puts).with(/code/)
        expect(subject).to receive(:puts).with(/body/)

        expect(subject.abs_is_valid_response?(test_http_response)).to eq(false)
      end

    end

    context 'when the response body is empty' do

      it 'reports the error and returns false' do
        expect(test_http_response).to receive(:nil?).at_least(:once).and_return(false)
        expect(test_http_response).to receive(:code).at_least(:once).and_return(TEST_VALID_RESPONSE_CODE)
        expect(test_http_response).to receive(:body).at_least(:once).and_return(TEST_INVALID_RESPONSE_BODY)

        allow(subject).to receive(:puts)
        expect(subject).to receive(:puts).with(/Invalid ABS response/)
        expect(subject).to receive(:puts).with(/code/)
        expect(subject).to receive(:puts).with(/body/)

        expect(subject.abs_is_valid_response?(test_http_response)).to eq(false)
      end

    end

    context 'when the response body is nil' do

      it 'reports the error and returns false' do
        expect(test_http_response).to receive(:nil?).at_least(:once).and_return(false)
        expect(test_http_response).to receive(:code).at_least(:once).and_return(TEST_VALID_RESPONSE_CODE)
        expect(test_http_response).to receive(:body).at_least(:once).and_return(nil)

        allow(subject).to receive(:puts)
        expect(subject).to receive(:puts).with(/Invalid ABS response/)
        expect(subject).to receive(:puts).with(/code/)
        expect(subject).to receive(:puts).with(/body/)

        expect(subject.abs_is_valid_response?(test_http_response)).to eq(false)
      end

    end

  end

  describe '#abs_get_a2a_hosts' do

    before {
      subject.instance_variable_set("@abs_aws_mom_size", TEST_ABS_AWS_MOM_SIZE)
      subject.instance_variable_set("@abs_aws_metrics_size", TEST_ABS_AWS_METRICS_SIZE)
    }

    context 'when called' do

      it 'initializes the helper and returns the a2a hosts' do
        expect(subject).to receive(:abs_initialize)
        expect(subject.abs_get_a2a_hosts).to eq(TEST_A2A_HOSTS)

      end

    end

  end

  describe '#abs_reformat_resource_host' do

    context 'when a valid response_body is provided' do

      it 'returns the expected reformatted response' do
        expect(subject.abs_reformat_resource_host(TEST_AWSDIRECT_RESPONSE_BODY)).to eq(TEST_REFORMATTED_RESPONSE_BODY)
      end

    end

    context 'when an invalid response_body is provided' do

      it 'reports the error and returns nil' do
        expect(subject).to receive(:puts).with("JSON::ParserError encountered parsing the response body: #{TEST_INVALID_RESPONSE_BODY}")
        expect(subject.abs_reformat_resource_host(TEST_INVALID_RESPONSE_BODY)).to eq(nil)
      end

    end

  end

  describe '#abs_update_last_abs_resource_hosts' do

    context 'when a host string is specified' do

      it 'writes the string to the log file' do
        skip
      end

    end
  end

  describe '#abs_get_resource_hosts' do

    context 'when a valid response is returned' do

      it 'sets the environment variable, logs the hosts, returns the response(s), reports no errors and does not return the hosts' do
        ENV['ABS_TOKEN'] = TEST_ABS_TOKEN
        expect(subject).to receive(:abs_initialize).once
        allow(TEST_ABS_RESOURCE_HOSTS).to receive(:each)

        expect(subject).to receive(:abs_get_awsdirect_request_body).with(:mom, TEST_ABS_AWS_MOM_SIZE).once.and_return(TEST_AWSDIRECT_MOM_REQUEST_BODY)
        expect(subject).to receive(:abs_get_awsdirect_request_body).with(:metrics, TEST_ABS_AWS_METRICS_SIZE).and_return(TEST_AWSDIRECT_METRICS_REQUEST_BODY)

        expect(subject).to receive(:abs_request_awsdirect).once.with(TEST_AWSDIRECT_URI, TEST_AWSDIRECT_MOM_REQUEST_BODY).and_return(test_http_response)
        expect(subject).to receive(:abs_request_awsdirect).once.with(TEST_AWSDIRECT_URI, TEST_AWSDIRECT_METRICS_REQUEST_BODY).and_return(test_http_response)

        expect(subject).to receive(:abs_is_valid_response?).at_least(:once).with(test_http_response).and_return(true)

        expect(test_http_response).to receive(:body).at_least(:once).and_return(TEST_AWSDIRECT_RESPONSE_BODY)
        expect(subject).to receive(:abs_reformat_resource_host).at_least(:once).with(TEST_AWSDIRECT_RESPONSE_BODY).and_return(TEST_REFORMATTED_RESPONSE_BODY)

        expect(subject).not_to receive(:puts).with(/Returning any provisioned hosts/)
        expect(subject).not_to receive(:puts).with(/Unable to provision host for role/)
        expect(subject).not_to receive(:puts).with(/No ABS hosts were provisioned/)

        expect(subject).not_to receive(:abs_return_resource_hosts)

        expect(subject.abs_get_resource_hosts(TEST_A2A_HOSTS)).to eq(TEST_ABS_RESOURCE_HOSTS)
      end

    end

    # TODO: verify error reporting or trust the tests for abs_is_valid_response?
    context 'when an invalid response is returned' do

      context 'when this is the first request' do

        it 'does not attempt to return hosts, reports the error and returns nil' do
          # TODO: set up and verify this being the first request
          ENV['ABS_TOKEN'] = TEST_ABS_TOKEN
          test_expected_result = nil

          expect(subject).to receive(:abs_request_awsdirect).once.and_return(test_http_response)
          expect(subject).to receive(:abs_is_valid_response?).once.with(test_http_response).and_return(false)

          allow(subject).to receive(:puts)
          expect(subject).not_to receive(:puts).with(/Returning any provisioned hosts/)
          expect(subject).not_to receive(:abs_return_resource_hosts)

          expect(subject).to receive(:puts).with(/Unable to provision host for role/)
          expect(subject).to receive(:puts).with(/No ABS hosts were provisioned/)

          expect(subject.abs_get_resource_hosts(TEST_A2A_HOSTS)).to eq(test_expected_result)
        end

      end

      context 'when there have been previous successful requests' do

        it 'attempts to return the previously provisioned hosts' do
          ENV['ABS_TOKEN'] = TEST_ABS_TOKEN
          expect(subject).to receive(:abs_initialize)
          allow(TEST_ABS_RESOURCE_HOSTS).to receive(:each)

          # valid
          expect(subject).to receive(:abs_get_awsdirect_request_body).with(:mom, TEST_ABS_AWS_MOM_SIZE).and_return(TEST_AWSDIRECT_MOM_REQUEST_BODY)
          expect(subject).to receive(:abs_request_awsdirect).with(TEST_AWSDIRECT_URI, TEST_AWSDIRECT_MOM_REQUEST_BODY).and_return(test_http_response)
          expect(subject).to receive(:abs_is_valid_response?).with(test_http_response).and_return(true)

          expect(test_http_response).to receive(:body).and_return(TEST_AWSDIRECT_RESPONSE_BODY)
          expect(subject).to receive(:abs_reformat_resource_host).with(TEST_AWSDIRECT_RESPONSE_BODY).and_return(TEST_REFORMATTED_RESPONSE_BODY)

          # invalid
          expect(subject).to receive(:abs_get_awsdirect_request_body).with(:metrics, TEST_ABS_AWS_METRICS_SIZE).and_return(TEST_AWSDIRECT_METRICS_REQUEST_BODY)
          expect(subject).to receive(:abs_request_awsdirect).with(TEST_AWSDIRECT_URI, TEST_AWSDIRECT_METRICS_REQUEST_BODY).and_return(nil)
          expect(subject).to receive(:abs_is_valid_response?).with(nil).and_return(false)

          allow(subject).to receive(:puts)
          expect(subject).to receive(:puts).with(/Returning any provisioned hosts/)
          expect(subject).to receive(:puts).with(/Unable to provision host for role: metrics/)

          expect(subject).not_to receive(:puts).with(/No ABS hosts were provisioned/)

          expect(subject).to receive(:abs_return_resource_hosts).with(TEST_ABS_RESOURCE_HOSTS_SINGLE).and_return(TEST_ABS_RESOURCE_HOSTS_SINGLE)
          expect(subject.abs_get_resource_hosts(TEST_A2A_HOSTS)).to eq(nil)
        end

      end

    end

  end

  describe '#abs_get_last_abs_resource_hosts' do

    context 'when the file exists' do

      context 'when the file contains a valid list of hosts' do

        it 'returns the hosts' do
          expect(File).to receive(:exist?).and_return(true)
          expect(File).to receive(:read).and_return(TEST_ABS_RESOURCE_HOSTS)
          expect(TEST_ABS_RESOURCE_HOSTS).to receive(:start_with?).and_return(true)

          expect(subject).to_not receive(:puts)

          expect(subject.abs_get_last_abs_resource_hosts).to eq(TEST_ABS_RESOURCE_HOSTS)
        end

      end

      context 'when the file does not contain a valid list of hosts' do

        it 'reports the error and returns nil' do
          expect(File).to receive(:exist?).and_return(true)
          expect(File).to receive(:read).and_return(TEST_ABS_RESOURCE_HOSTS)
          expect(TEST_ABS_RESOURCE_HOSTS).to receive(:start_with?).and_return(false)

          allow(subject).to receive(:puts)
          expect(subject).to receive(:puts).with(/Invalid last ABS resource hosts file/)

          expect(subject.abs_get_last_abs_resource_hosts).to eq(nil)
        end

      end

      context 'when the file is empty' do

        it 'reports the error and returns nil' do
          test_file = ''

          expect(File).to receive(:exist?).and_return(true)
          expect(File).to receive(:read).and_return(test_file)
          expect(test_file).to receive(:start_with?).and_return(false)

          allow(subject).to receive(:puts)
          expect(subject).to receive(:puts).with(/Invalid last ABS resource hosts file/)

          expect(subject.abs_get_last_abs_resource_hosts).to eq(nil)
        end

      end

    end

    context 'when the file does not exist' do

      it 'reports the error and returns nil' do
        expect(File).to receive(:exist?).and_return(false)
        expect(File).not_to receive(:read)

        allow(subject).to receive(:puts)
        expect(subject).to receive(:puts).with(/Last ABS resource hosts file not found/)

        expect(subject.abs_get_last_abs_resource_hosts).to eq(nil)
      end

    end

  end

  describe '#abs_return_resource_hosts' do

    test_uri = TEST_AWSDIRECTRETURN_URI
    test_body = TEST_AWSDIRECTRETURN_REQUEST_BODY

    context 'when an array of hosts is specified' do

      context 'when the responses are valid' do

        it 'submits requests to return the hosts and returns the expected host array' do
          expect(subject).to receive(:abs_initialize)
          expect(subject).to receive(:abs_get_awsdirectreturn_request_body).with(TEST_HOSTNAME).at_least(:once).and_return(test_body)
          expect(subject).to receive(:abs_request_awsdirect).with(test_uri, test_body).at_least(:once).and_return(test_http_response)
          expect(subject).to receive(:abs_is_valid_response?).at_least(:once).with(test_http_response).and_return(true)

          allow(subject).to receive(:puts)
          expect(subject).not_to receive(:puts).with(/De-provisioning via return_abs_resource_hosts requires an array of hostnames/)

          expect(subject.abs_return_resource_hosts(TEST_ABS_RESOURCE_HOSTS)).to eq(TEST_ABS_RESOURCE_HOSTS)
        end

      end

      context 'when the responses are not valid' do

        it 'submits requests to return the hosts, reports the errors, returns nil' do
          expect(subject).to receive(:abs_initialize)
          expect(subject).to receive(:abs_get_awsdirectreturn_request_body).with(TEST_HOSTNAME).at_least(:once).and_return(test_body)
          expect(subject).to receive(:abs_request_awsdirect).with(test_uri, test_body).at_least(:once).and_return(test_http_response)

          expect(subject).to receive(:abs_is_valid_response?).at_least(:once).with(test_http_response).and_return(false)

          allow(subject).to receive(:puts)
          expect(subject).to receive(:puts).with(/Failed to return host/)

          expect(subject.abs_return_resource_hosts(TEST_ABS_RESOURCE_HOSTS)).to eq(nil)
        end

      end

      context 'when a mix of valid and invalid responses are returned' do

        it 'submits requests to return the hosts, reports the errors, returns the successfully returned hosts' do
          skip
        end

      end

    end

    context 'when an array of hosts is not specified' do

      # TODO: improve
      it 'reports the error and returns nil' do
        expect(subject).to receive(:abs_initialize)

        allow(subject).to receive(:puts)
        expect(subject).to receive(:puts).with(/De-provisioning via return_abs_resource_hosts requires an array of hostnames/)

        expect(subject.abs_return_resource_hosts(nil)).to eq(nil)
      end

    end

  end

end
