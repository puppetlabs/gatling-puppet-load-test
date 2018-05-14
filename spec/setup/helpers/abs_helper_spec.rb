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
  TEST_BASE_URL = 'https://testing.puppet.net/v2'
  TEST_AWSDIRECT_URL = "#{TEST_BASE_URL}/awsdirect"
  TEST_AWSDIRECT_URI = URI(TEST_AWSDIRECT_URL)
  TEST_AWSDIRECTRETURN_URL = "#{TEST_BASE_URL}/awsdirectreturn"
  TEST_AWSDIRECTRETURN_URI = URI(TEST_AWSDIRECTRETURN_URL)

  TEST_HOSTNAME = 'testing.puppet.net'
  TEST_ABS_TYPE = 'el-7-x86_64'
  TEST_BEAKER_TYPE = 'centos-7-x86-64-west'
  TEST_ENGINE = 'aws'

  TEST_AWSDIRECT_REQUEST_BODY =
    { 'platform': 'amazon-6-x86_64',
      'image_id': 'ami-a07379d9',
      'size': 'c3.large',
      'region': 'us-west-2',
      'reap_time': 10800,
      'tags':
          {'field1': 'value1', 'field2': 'value2'}
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

  TEST_INVALID_RESPONSE_BODY = ''
  TEST_VALID_RESPONSE_CODE = '200'
  TEST_INVALID_RESPONSE_CODE = '777'

  TEST_ABS_RESOURCE_HOSTS = [
      { 'hostname': TEST_HOSTNAME,
        'type': TEST_BEAKER_TYPE,
        'engine': TEST_ENGINE},
      { 'hostname': TEST_HOSTNAME,
        'type': TEST_BEAKER_TYPE,
        'engine': TEST_ENGINE}].to_json

  TEST_A2A_HOSTS = {'mom': 'c4.2xlarge', 'metrics': 'c4.2xlarge'}

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

        it 'returns nil' do
          fog_file =
              ':default:
              :not_abs_token: xyz123'

          expect(File).to receive(:exist?).and_return(true)
          expect(File).to receive(:read).and_return(fog_file)

          expect(subject.abs_get_token_from_fog_file).to eq(nil)
        end

      end

    end

    context 'when the .fog file does not exist' do

      it 'reports the error and returns nil' do
        expect(File).to receive(:exist?).and_return(false)
        expect(subject).to receive(:puts).at_least(:once)

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
          expect(subject).to receive(:puts)
          expect(subject.abs_get_token).to eq(nil)
        end

      end

    end

  end

  describe '#abs_request_awsdirect' do

    context 'when a valid uri and body are specified' do

      it 'returns the response' do
        expect(subject).to receive(:abs_get_request_post).and_return(test_http_request)
        allow(test_http_request).to receive(:body=)

        stub_const('Net::HTTP', test_net_http)
        allow(test_net_http).to receive(:new).and_return(test_net_http_instance)

        allow(test_net_http_instance).to receive(:use_ssl=)
        allow(test_net_http_instance).to receive(:read_timeout=)
        expect(test_net_http_instance).to receive(:request).with(test_http_request).and_return(test_http_response)

        allow(test_http_response).to receive(:body)

        expect(subject.abs_request_awsdirect(TEST_AWSDIRECT_URI, TEST_AWSDIRECT_REQUEST_BODY)).to eq(test_http_response)

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

      it 'returns false' do
        expect(subject.abs_is_valid_response?(nil)).to eq(false)
      end

    end

    context 'when the response code is not valid' do

      it 'returns false' do
        expect(test_http_response).to receive(:nil?).at_least(:once).and_return(false)
        expect(test_http_response).to receive(:code).at_least(:once).and_return(TEST_INVALID_RESPONSE_CODE)
        expect(test_http_response).to receive(:body).at_least(:once).and_return(TEST_AWSDIRECT_RESPONSE_BODY)

        expect(subject.abs_is_valid_response?(test_http_response)).to eq(false)
      end

    end

    context 'when the response body is empty' do

      it 'returns false' do
        expect(test_http_response).to receive(:nil?).at_least(:once).and_return(false)
        expect(test_http_response).to receive(:code).at_least(:once).and_return(TEST_VALID_RESPONSE_CODE)
        expect(test_http_response).to receive(:body).at_least(:once).and_return(TEST_INVALID_RESPONSE_BODY)

        expect(subject.abs_is_valid_response?(test_http_response)).to eq(false)
      end

    end

    context 'when the response body is nil' do

      it 'returns false' do
        expect(test_http_response).to receive(:nil?).at_least(:once).and_return(false)
        expect(test_http_response).to receive(:code).at_least(:once).and_return(TEST_VALID_RESPONSE_CODE)
        expect(test_http_response).to receive(:body).at_least(:once).and_return(nil)

        expect(subject.abs_is_valid_response?(test_http_response)).to eq(false)
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
        expect(subject).to receive(:puts).with('JSON::ParserError encountered')
        expect(subject.abs_reformat_resource_host(TEST_INVALID_RESPONSE_BODY)).to eq(nil)

      end

    end

  end

  describe '#abs_get_resource_hosts' do

    context 'when a valid response is returned' do

      it 'sets the environment variable, logs the hosts, and returns the response(s)' do
        ENV['ABS_TOKEN'] = TEST_ABS_TOKEN
        expect(subject).to receive(:abs_request_awsdirect).at_least(:once).and_return(test_http_response)

        expect(test_http_response).to receive(:nil?).at_least(:once).and_return(false)
        expect(test_http_response).to receive(:code).at_least(:once).and_return(TEST_VALID_RESPONSE_CODE)
        expect(test_http_response).to receive(:body).at_least(:once).and_return(TEST_AWSDIRECT_RESPONSE_BODY)

        expect(subject.abs_get_resource_hosts).to eq(TEST_ABS_RESOURCE_HOSTS)
      end

    end

    context 'when an invalid response code is returned' do

      it 'reports the error and returns nil' do
        ENV['ABS_TOKEN'] = TEST_ABS_TOKEN
        test_expected_result = nil

        expect(subject).to receive(:abs_request_awsdirect).at_least(:once).and_return(test_http_response)

        expect(test_http_response).to receive(:nil?).at_least(:once).and_return(false)
        expect(test_http_response).to receive(:code).at_least(:once).and_return(TEST_INVALID_RESPONSE_CODE)
        expect(test_http_response).to receive(:body).at_least(:once).and_return(TEST_INVALID_RESPONSE_BODY)

        expect(subject.abs_get_resource_hosts).to eq(test_expected_result)
      end

    end

    context 'when an invalid response body is returned' do

      it 'reports the error and returns nil' do
        ENV['ABS_TOKEN'] = TEST_ABS_TOKEN
        test_expected_result = nil

        expect(subject).to receive(:abs_request_awsdirect).at_least(:once).and_return(test_http_response)

        expect(test_http_response).to receive(:nil?).at_least(:once).and_return(false)
        expect(test_http_response).to receive(:code).at_least(:once).and_return(TEST_VALID_RESPONSE_CODE)
        expect(test_http_response).to receive(:body).at_least(:once).and_return(TEST_INVALID_RESPONSE_BODY)

        expect(subject.abs_get_resource_hosts).to eq(test_expected_result)
      end

    end

    context 'when the response is nil' do

      it 'reports the error and returns nil' do
        ENV['ABS_TOKEN'] = TEST_ABS_TOKEN
        test_expected_result = nil

        expect(subject).to receive(:abs_request_awsdirect).at_least(:once).and_return(nil)
        expect(subject.abs_get_resource_hosts).to eq(test_expected_result)
      end

    end

  end

  describe '#abs_get_last_abs_resource_hosts' do

    context 'when the file exists' do

      context 'when the file contains a valid list of hosts' do

        it 'returns the hosts' do
          skip
        end

      end

      context 'when the file does not contain a valid list of hosts' do

        it 'reports the error and returns nil' do
          skip
        end

      end

      context 'when the file is empty' do

        it 'reports the error and returns nil' do
          skip
        end

      end

    end

    context 'when the file does not exist' do

      it 'reports the error and returns nil' do
        skip
      end

    end

  end

  describe '#return_abs_resource_hosts' do

    test_uri = TEST_AWSDIRECTRETURN_URI
    test_body = TEST_AWSDIRECTRETURN_REQUEST_BODY

    context 'when an array of hosts is specified via ABS_RESOURCE_HOSTS' do

      it 'submits requests to return the hosts and returns the host array' do
        ENV['ABS_RESOURCE_HOSTS'] = TEST_ABS_RESOURCE_HOSTS

        expect(subject).to receive(:abs_get_base_url).at_least(:once).and_return(TEST_BASE_URL)

        expect(subject).to receive(:get_abs_awsdirectreturn_request_body).with(TEST_HOSTNAME).at_least(:once).and_return(test_body)
        expect(subject).to receive(:abs_request_awsdirect).with(test_uri, test_body).at_least(:once).and_return(nil)

        expect(subject.return_abs_resource_hosts).to include(TEST_ABS_RESOURCE_HOSTS)
      end

    end

    context 'when an array of hosts is specified via last_abs_resource_hosts.log' do

      it 'submits requests to returns the hosts and returns the host array' do
        ENV['ABS_RESOURCE_HOSTS'] = nil

        expect(subject).to receive(:abs_get_base_url).at_least(:once).and_return(TEST_BASE_URL)

        expect(subject).to receive(:abs_get_last_abs_resource_hosts).at_least(:once).and_return(TEST_ABS_RESOURCE_HOSTS)

        expect(subject).to receive(:get_abs_awsdirectreturn_request_body).with(TEST_HOSTNAME).at_least(:once).and_return(test_body)
        expect(subject).to receive(:abs_request_awsdirect).with(test_uri, test_body).at_least(:once).and_return(nil)

        expect(subject.return_abs_resource_hosts).to include(TEST_ABS_RESOURCE_HOSTS)
      end

    end

    context 'when an array of hosts is not specified' do

      # TODO: improve
      it 'reports the error and returns nil' do
        ENV['ABS_RESOURCE_HOSTS'] = nil

        expect(subject).to receive(:abs_get_base_url).at_least(:once).and_return(TEST_BASE_URL)

        expect(subject).to receive(:abs_get_last_abs_resource_hosts).at_least(:once).and_return(nil)
        expect(subject.return_abs_resource_hosts).to eq(nil)

      end

    end

  end

end
