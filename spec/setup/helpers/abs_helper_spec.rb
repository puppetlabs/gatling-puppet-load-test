require "./setup/helpers/abs_helper"
require "net/ssh/errors"

class AbsHelperClass
  include AbsHelper
end

describe AbsHelperClass do
  let(:test_net_http) { Class.new }
  let(:test_net_http_instance) { Class.new }
  let(:test_net_http_post) { Class.new }
  let(:test_http_request) { Class.new }
  let(:test_http_response) { Class.new }

  TEST_ABS_TOKEN = "test_abs_token_zzz".freeze
  TEST_ABS_BASE_URL = "https://testing.puppet.net/v2".freeze
  TEST_PLATFORM = "test-amazon-6-x86_64".freeze
  TEST_IMAGE_ID = "test-ami-a07379d9".freeze
  TEST_SIZE = "test.c3.large".freeze
  TEST_VOLUME_SIZE = "80".freeze
  TEST_REGION = "test-us-west-2".freeze
  TEST_REAP_TIME = "12345".freeze

  # TODO: update to use different values for mom and metrics
  TEST_MOM_ROLE = "mom".freeze
  TEST_MOM_SIZE = TEST_SIZE
  TEST_MOM_VOLUME_SIZE = TEST_VOLUME_SIZE
  TEST_METRICS_ROLE = "metrics".freeze
  TEST_METRICS_SIZE = TEST_SIZE
  TEST_METRICS_VOLUME_SIZE = TEST_VOLUME_SIZE

  TEST_AWSDIRECT_URL = "#{TEST_ABS_BASE_URL}/awsdirect".freeze
  TEST_AWSDIRECT_URI = URI(TEST_AWSDIRECT_URL).freeze
  TEST_AWSDIRECTRETURN_URL = "#{TEST_ABS_BASE_URL}/awsdirectreturn".freeze
  TEST_AWSDIRECTRETURN_URI = URI(TEST_AWSDIRECTRETURN_URL).freeze

  TEST_HOSTNAME = "testing.puppet.net".freeze
  TEST_HOSTNAME_MOM = "mom.puppet.net".freeze
  TEST_HOSTNAME_METRICS = "metrics.puppet.net".freeze

  TEST_ABS_TYPE = "el-7-x86_64".freeze
  TEST_BEAKER_TYPE = "centos-7-x86-64-west".freeze
  TEST_ENGINE = "aws".freeze
  TEST_BEAKER_PE_VERSION = "2018.1.0-rc17".freeze
  TEST_ROLE = "test-role".freeze

  TEST_EXPECTED_REQUEST_HEADERS = { "Content-Type" => "application/json",
                                    "X-Auth-Token" => TEST_ABS_TOKEN }.freeze

  TEST_AWSDIRECT_REQUEST_BODY =
    { 'platform': TEST_PLATFORM,
      'image_id': TEST_IMAGE_ID,
      'size': TEST_SIZE,
      'region': TEST_REGION,
      'reap_time': TEST_REAP_TIME,
      'tags':
          { 'role': TEST_ROLE, 'pe_version': TEST_BEAKER_PE_VERSION },
      'volume_size': TEST_VOLUME_SIZE }.to_json.freeze

  TEST_AWSDIRECT_MOM_REQUEST_BODY =
    { 'platform': TEST_PLATFORM,
      'image_id': TEST_IMAGE_ID,
      'size': TEST_MOM_SIZE,
      'region': TEST_REGION,
      'reap_time': TEST_REAP_TIME,
      'tags':
          { 'role': "mom", 'pe_version': "value2" },
      'volume_size': TEST_VOLUME_SIZE }.to_json.freeze

  TEST_AWSDIRECT_METRICS_REQUEST_BODY =
    { 'platform': TEST_PLATFORM,
      'image_id': TEST_IMAGE_ID,
      'size': TEST_METRICS_SIZE,
      'region': TEST_REGION,
      'reap_time': TEST_REAP_TIME,
      'tags':
          { 'field1': "value1", 'pe_version': "value2" },
      'volume_size': TEST_VOLUME_SIZE }.to_json.freeze

  TEST_AWSDIRECT_RESPONSE_BODY =
    { 'hostname': TEST_HOSTNAME,
      'instance_id': "i-0721e8f28c67a0axx",
      'type': TEST_BEAKER_TYPE }.to_json.freeze

  TEST_REFORMATTED_RESPONSE_BODY =
    { 'hostname': TEST_HOSTNAME,
      'type': TEST_BEAKER_TYPE,
      'engine': TEST_ENGINE }.to_json.freeze

  TEST_HOST =
    { 'hostname': TEST_HOSTNAME,
      'type': TEST_BEAKER_TYPE,
      'engine': TEST_ENGINE }.freeze

  TEST_AWSDIRECTRETURN_REQUEST_BODY = { 'hostname': TEST_HOSTNAME }.to_json.freeze

  TEST_VALID_RESPONSE_BODY = "OK".freeze
  TEST_INVALID_RESPONSE_BODY = "".freeze
  TEST_VALID_RESPONSE_CODE = "200".freeze
  TEST_INVALID_RESPONSE_CODE = "777".freeze

  TEST_A2A_MOM =
    { 'role': "mom",
      'size': TEST_SIZE,
      'volume_size': TEST_VOLUME_SIZE }.freeze

  TEST_A2A_METRICS =
    { 'role': "metrics",
      'size': TEST_SIZE,
      'volume_size': TEST_VOLUME_SIZE }.freeze

  TEST_A2A_HOSTS = [TEST_A2A_MOM, TEST_A2A_METRICS].freeze

  # TODO: update to use mom and metrics
  TEST_ABS_HOSTS = [TEST_HOST, TEST_HOST].freeze

  # the final result is converted back to json
  TEST_ABS_RESOURCE_HOSTS_SINGLE = [TEST_HOST].to_json.freeze
  TEST_ABS_RESOURCE_HOSTS = TEST_ABS_HOSTS.to_json

  TEST_INVALID_ABS_RESOURCE_HOSTS = [
    { 'hostz': TEST_HOSTNAME,
      'typez': TEST_BEAKER_TYPE,
      'enginez': TEST_ENGINE },
    { 'hostz': TEST_HOSTNAME,
      'typez': TEST_BEAKER_TYPE,
      'enginez': TEST_ENGINE }
  ].to_json.freeze

  before do
    ENV["BEAKER_PE_VER"] = TEST_BEAKER_PE_VERSION
    subject.instance_variable_set(:@abs_base_url, TEST_ABS_BASE_URL)
    subject.instance_variable_set(:@abs_beaker_pe_version, TEST_BEAKER_PE_VERSION)
  end

  describe "#abs_initialize" do
    context "when the user has a token" do
      context "when environment variables are specified" do
        it "sets the properties to the specified values and returns true" do
          ENV["ABS_TOKEN"] = TEST_ABS_TOKEN

          ENV["ABS_BASE_URL"] = TEST_ABS_BASE_URL
          ENV["ABS_AWS_PLATFORM"] = TEST_PLATFORM
          ENV["ABS_AWS_IMAGE_ID"] = TEST_IMAGE_ID
          ENV["ABS_AWS_VOLUME_SIZE"] = TEST_VOLUME_SIZE
          ENV["ABS_AWS_REGION"] = TEST_REGION
          ENV["ABS_AWS_REAP_TIME"] = TEST_REAP_TIME
          ENV["ABS_AWS_MOM_SIZE"] = TEST_MOM_SIZE
          ENV["ABS_AWS_METRICS_SIZE"] = TEST_METRICS_SIZE
          ENV["BEAKER_PE_VER"] = TEST_BEAKER_PE_VERSION

          expect(subject).to receive(:get_abs_token).and_return(TEST_ABS_TOKEN)
          expect(subject.abs_initialize).to eq(true)

          expect(subject.instance_variable_get(:@abs_base_url)).to eq(TEST_ABS_BASE_URL)
          expect(subject.instance_variable_get(:@aws_platform)).to eq(TEST_PLATFORM)
          expect(subject.instance_variable_get(:@aws_image_id)).to eq(TEST_IMAGE_ID)
          expect(subject.instance_variable_get(:@aws_region)).to eq(TEST_REGION)
          expect(subject.instance_variable_get(:@aws_reap_time)).to eq(TEST_REAP_TIME)
          expect(subject.instance_variable_get(:@mom_size)).to eq(TEST_MOM_SIZE)
          expect(subject.instance_variable_get(:@metrics_size))
            .to eq(TEST_METRICS_SIZE)
          expect(subject.instance_variable_get(:@abs_beaker_pe_version))
            .to eq(TEST_BEAKER_PE_VERSION)
        end
      end

      context "when environment variables are not specified" do
        it "sets the properties to the default values and returns true" do
          pending "resolve stubbed constant issue"

          ENV["ABS_BASE_URL"] = nil
          ENV["ABS_AWS_PLATFORM"] = nil
          ENV["ABS_AWS_IMAGE_ID"] = nil
          ENV["ABS_AWS_REGION"] = nil
          ENV["ABS_AWS_REAP_TIME"] = nil
          ENV["ABS_AWS_MOM_SIZE"] = nil
          ENV["ABS_AWS_METRICS_SIZE"] = nil

          stub_const("ABS_BASE_URL", TEST_ABS_BASE_URL)
          stub_const("ABS_AWS_PLATFORM", TEST_PLATFORM)
          stub_const("ABS_AWS_IMAGE_ID", TEST_IMAGE_ID)
          stub_const("ABS_AWS_MOM_SIZE", TEST_MOM_SIZE)
          stub_const("ABS_AWS_METRICS_SIZE", TEST_METRICS_SIZE)
          stub_const("ABS_AWS_REGION", TEST_REGION)
          stub_const("ABS_AWS_REAP_TIME", TEST_REAP_TIME)

          # TODO: stubbed constants aren't used by the properties in the code under test
          # subject.abs_initialize

          expect(subject.instance_variable_get(:@abs_base_url)).to eq(TEST_ABS_BASE_URL)
          expect(subject.instance_variable_get(:@aws_platform)).to eq(TEST_PLATFORM)
          expect(subject.instance_variable_get(:@aws_image_id)).to eq(TEST_IMAGE_ID)
          expect(subject.instance_variable_get(:@aws_region)).to eq(TEST_REGION)
          expect(subject.instance_variable_get(:@aws_reap_time)).to eq(TEST_REAP_TIME)
          expect(subject.instance_variable_get(:@mom_size)).to eq(TEST_MOM_SIZE)
          expect(subject.instance_variable_get(:@metrics_size))
            .to eq(TEST_METRICS_SIZE)

          subject.abs_initialize
        end
      end
    end

    context "when the user does not have a token" do
      it "returns false" do
        ENV["ABS_TOKEN"] = nil

        expect(subject).to receive(:get_abs_token).and_return(false)
        expect(subject.abs_initialize).to eq(false)
      end
    end
  end

  describe "#get_a2a_hosts" do
    before do
      subject.instance_variable_set("@mom_size", TEST_MOM_SIZE)
      subject.instance_variable_set("@mom_volume_size", TEST_MOM_VOLUME_SIZE)
      subject.instance_variable_set("@metrics_size", TEST_METRICS_SIZE)
      subject.instance_variable_set("@metrics_volume_size", TEST_METRICS_VOLUME_SIZE)
    end

    context "when called" do
      it "initializes the helper and returns the a2a hosts" do
        expect(subject).to receive(:abs_initialize)
        expect(subject.get_a2a_hosts).to eq(TEST_A2A_HOSTS)
      end
    end
  end

  describe "#get_abs_resource_hosts" do
    context "when a valid token is present" do
      context "when a valid response is returned" do
        it "sets the environment variable, logs the hosts, and returns the response(s)" do
          ENV["ABS_TOKEN"] = TEST_ABS_TOKEN

          expect(subject).to receive(:abs_initialize).and_return(true)
          expect(subject).to receive(:puts)
            .with("Attempting to provision ABS hosts: #{TEST_A2A_HOSTS}")

          allow(TEST_ABS_RESOURCE_HOSTS).to receive(:each)

          expect(subject).to receive(:get_abs_resource_host)
            .with(TEST_A2A_MOM).and_return(TEST_HOST)

          expect(subject).to receive(:get_abs_resource_host)
            .with(TEST_A2A_METRICS).and_return(TEST_HOST)

          expect(subject).to receive(:update_last_abs_resource_hosts)
            .with(TEST_ABS_RESOURCE_HOSTS)

          expect(subject).to receive(:verify_abs_hosts)
            .with(TEST_ABS_HOSTS).and_return(true)

          expect(subject).not_to receive(:puts).with(/Returning any provisioned hosts/)
          expect(subject).not_to receive(:puts).with(/No ABS hosts were provisioned/)

          expect(subject).not_to receive(:return_abs_resource_hosts)

          expect(subject.get_abs_resource_hosts(TEST_A2A_HOSTS)).to eq(TEST_ABS_RESOURCE_HOSTS)
        end
      end

      # TODO: verify error reporting or trust the tests for abs_is_valid_response?
      context "when an invalid response is returned" do
        context "when there have been no valid responses" do
          it "does not attempt to return hosts, reports the error and returns nil" do
            ENV["ABS_TOKEN"] = TEST_ABS_TOKEN
            error_message = "Unable to provision host for role: #{TEST_A2A_MOM[:role]}"

            expect(subject).to receive(:abs_initialize).and_return(true)
            expect(subject).to receive(:puts)
              .with("Attempting to provision ABS hosts: #{TEST_A2A_HOSTS}")

            allow(TEST_ABS_RESOURCE_HOSTS).to receive(:each)

            expect(subject).to receive(:get_abs_resource_host)
              .with(TEST_A2A_MOM).and_raise(RuntimeError, error_message)

            expect(subject).to receive(:puts).with("No ABS hosts were provisioned")

            expect(subject).not_to receive(:puts).with("Returning any provisioned hosts")
            expect(subject).not_to receive(:return_abs_resource_hosts)

            expect(subject).not_to receive(:update_last_abs_resource_hosts)
            expect(subject).not_to receive(:verify_abs_hosts)

            expect { subject.get_abs_resource_hosts(TEST_A2A_HOSTS) }
              .to raise_error(RuntimeError, error_message)
          end
        end

        context "when there have been valid responses" do
          it "attempts to return the previously provisioned hosts" do
            ENV["ABS_TOKEN"] = TEST_ABS_TOKEN
            error_message = "Unable to provision host for role: #{TEST_A2A_METRICS[:role]}"

            expect(subject).to receive(:abs_initialize).and_return(true)
            allow(TEST_ABS_RESOURCE_HOSTS).to receive(:each)

            allow(subject).to receive(:puts)
            expect(subject).to receive(:puts)
              .with("Attempting to provision ABS hosts: #{TEST_A2A_HOSTS}")

            # valid
            expect(subject).to receive(:get_abs_resource_host)
              .with(TEST_A2A_MOM).and_return(TEST_HOST)

            # invalid
            expect(subject).to receive(:get_abs_resource_host)
              .with(TEST_A2A_METRICS).and_raise(RuntimeError, error_message)

            expect(subject).to receive(:return_abs_resource_hosts)
              .with(TEST_ABS_RESOURCE_HOSTS_SINGLE)
              .and_return(TEST_ABS_RESOURCE_HOSTS_SINGLE)

            expect(subject).not_to receive(:update_last_abs_resource_hosts)
            expect(subject).not_to receive(:verify_abs_hosts)

            expect { subject.get_abs_resource_hosts(TEST_A2A_HOSTS) }
              .to raise_error(RuntimeError, error_message)
          end
        end
      end
    end

    context "when a valid token is not present" do
      it "does not make the request, reports the error and returns nil" do
        ENV["ABS_TOKEN"] = "not_a_token"
        expect(subject).to receive(:abs_initialize).and_return(false)

        expect(subject).not_to receive(:puts)
          .with("Attempting to provision ABS hosts: #{TEST_A2A_HOSTS}")

        expect(TEST_ABS_RESOURCE_HOSTS).not_to receive(:each)
        expect(subject).not_to receive(:get_awsdirect_request_body)
        expect(subject).not_to receive(:perform_awsdirect_request)
        expect(subject).not_to receive(:puts).with(/Returning any provisioned hosts/)
        expect(subject).not_to receive(:puts).with(/Unable to provision host for role/)
        expect(subject).not_to receive(:puts).with(/No ABS hosts were provisioned/)
        expect(subject).not_to receive(:return_abs_resource_hosts)
        expect(subject).not_to receive(:update_last_abs_resource_hosts)
        expect(subject).not_to receive(:verify_abs_hosts)

        expect { subject.get_abs_resource_hosts(TEST_A2A_HOSTS) }
          .to raise_error(RuntimeError, /Unable to proceed without a valid ABS token/)
      end
    end
  end

  describe "#get_abs_resource_host" do
    context "when the response is valid" do
      it "parses the response and returns the host" do
        expect(subject).to receive(:puts).with("Host_to_request: #{TEST_A2A_MOM}")

        expect(subject).to receive(:get_awsdirect_request_body)
          .with(TEST_A2A_MOM).and_return(TEST_AWSDIRECT_REQUEST_BODY)

        expect(subject).to receive(:perform_awsdirect_request).and_return(test_http_response)

        expect(subject).to receive(:valid_abs_response?)
          .with(test_http_response).and_return(true)

        expect(test_http_response).to receive(:body).and_return(TEST_AWSDIRECT_RESPONSE_BODY)
        expect(subject).to receive(:parse_awsdirect_response_body)
          .with(TEST_AWSDIRECT_RESPONSE_BODY).and_return(TEST_HOST)

        expect(subject.get_abs_resource_host(TEST_A2A_MOM)).to eq(TEST_HOST)
      end
    end

    context "when the response is not valid" do
      it "does not parse the response and raises an error" do
        error_message = "Unable to provision host for role: #{TEST_A2A_MOM[:role]}"

        expect(subject).to receive(:puts).with("Host_to_request: #{TEST_A2A_MOM}")

        expect(subject).to receive(:get_awsdirect_request_body)
          .with(TEST_A2A_MOM).and_return(TEST_AWSDIRECT_REQUEST_BODY)

        expect(subject).to receive(:perform_awsdirect_request).and_return(test_http_response)

        expect(test_http_response).not_to receive(:body)
        expect(subject).not_to receive(:parse_awsdirect_response_body)

        expect(subject).to receive(:valid_abs_response?)
          .with(test_http_response).and_return(false)

        expect { subject.get_abs_resource_host(TEST_A2A_MOM) }
          .to raise_error(RuntimeError, error_message)
      end
    end
  end

  describe "#return_abs_resource_hosts" do
    test_uri = TEST_AWSDIRECTRETURN_URI
    test_body = TEST_AWSDIRECTRETURN_REQUEST_BODY

    context "when a valid token is present and array of hosts is specified" do
      context "when the responses are valid" do
        it "submits requests to return the hosts and returns the expected host array" do
          expect(subject).to receive(:abs_initialize).and_return(true)
          expect(subject).to receive(:valid_abs_resource_hosts?)
            .with(TEST_ABS_RESOURCE_HOSTS).and_return(true)

          expect(subject).to receive(:get_awsdirectreturn_request_body)
            .with(TEST_HOSTNAME).at_least(:once).and_return(test_body)
          expect(subject).to receive(:perform_awsdirect_request)
            .with(test_uri, test_body).at_least(:once).and_return(test_http_response)
          expect(subject).to receive(:valid_abs_response?)
            .with(test_http_response).at_least(:once).and_return(true)

          allow(subject).to receive(:puts)
          expect(subject).not_to receive(:puts).with(/De-provisioning/)

          expect(subject.return_abs_resource_hosts(TEST_ABS_RESOURCE_HOSTS))
            .to eq(TEST_ABS_RESOURCE_HOSTS)
        end
      end

      context "when the responses are not valid" do
        it "submits requests to return the hosts, reports the errors, returns nil" do
          returned_hosts = "[]"

          expect(subject).to receive(:abs_initialize).and_return(true)
          expect(subject).to receive(:valid_abs_resource_hosts?)
            .with(TEST_ABS_RESOURCE_HOSTS).and_return(true)

          expect(subject).to receive(:get_awsdirectreturn_request_body)
            .with(TEST_HOSTNAME).at_least(:once).and_return(test_body)
          expect(subject).to receive(:perform_awsdirect_request)
            .with(test_uri, test_body).at_least(:once).and_return(test_http_response)

          expect(subject).to receive(:valid_abs_response?)
            .with(test_http_response).at_least(:once).and_return(false)

          allow(subject).to receive(:puts)
          expect(subject).to receive(:puts).with(/Failed to return host/)

          expect(subject.return_abs_resource_hosts(TEST_ABS_RESOURCE_HOSTS)).to eq(returned_hosts)
        end
      end

      context "when a mix of valid and invalid responses are returned" do
        it "submits requests to return the hosts, reports the errors, returns the hosts" do
          skip
        end
      end
    end

    context "when an array of hosts is not specified" do
      # TODO: improve
      it "reports the error and returns nil" do
        returned_hosts = "[]"

        expect(subject).to receive(:abs_initialize).and_return(true)
        expect(subject).to receive(:valid_abs_resource_hosts?).with(nil).and_return(false)

        allow(subject).to receive(:puts)
        expect(subject).to receive(:puts)
          .with(/De-provisioning via awsdirectreturn requires an array of hostnames/)

        expect(subject.return_abs_resource_hosts(nil)).to eq(returned_hosts)
      end
    end

    context "when a valid token is not present" do
      it "does not make the request, reports the error and returns nil" do
        returned_hosts = "[]"

        expect(subject).to receive(:abs_initialize).and_return(false)
        expect(subject).to receive(:valid_abs_resource_hosts?).and_return(true)

        allow(subject).to receive(:puts)
        expect(subject).to receive(:puts).with("Unable to proceed without a valid ABS token")

        expect(subject.return_abs_resource_hosts(nil)).to eq(returned_hosts)
      end
    end
  end

  describe "#get_last_abs_resource_hosts" do
    context "when the file exists" do
      context "when the file contains a valid list of hosts" do
        it "returns the hosts" do
          expect(File).to receive(:exist?).and_return(true)
          expect(File).to receive(:read).and_return(TEST_ABS_RESOURCE_HOSTS)
          expect(TEST_ABS_RESOURCE_HOSTS).to receive(:start_with?).and_return(true)

          expect(subject).to_not receive(:puts)

          expect(subject.get_last_abs_resource_hosts).to eq(TEST_ABS_RESOURCE_HOSTS)
        end
      end

      context "when the file does not contain a valid list of hosts" do
        it "reports the error and returns nil" do
          expect(File).to receive(:exist?).and_return(true)
          expect(File).to receive(:read).and_return(TEST_ABS_RESOURCE_HOSTS)
          expect(TEST_ABS_RESOURCE_HOSTS).to receive(:start_with?).and_return(false)

          allow(subject).to receive(:puts)
          expect(subject).to receive(:puts).with(/Invalid last ABS resource hosts file/)

          expect(subject.get_last_abs_resource_hosts).to eq(nil)
        end
      end

      context "when the file is empty" do
        it "reports the error and returns nil" do
          test_file = ""

          expect(File).to receive(:exist?).and_return(true)
          expect(File).to receive(:read).and_return(test_file)
          expect(test_file).to receive(:start_with?).and_return(false)

          allow(subject).to receive(:puts)
          expect(subject).to receive(:puts).with(/Invalid last ABS resource hosts file/)

          expect(subject.get_last_abs_resource_hosts).to eq(nil)
        end
      end
    end

    context "when the file does not exist" do
      it "reports the error and returns nil" do
        expect(File).to receive(:exist?).and_return(false)
        expect(File).not_to receive(:read)

        allow(subject).to receive(:puts)
        expect(subject).to receive(:puts).with(/Last ABS resource hosts file not found/)

        expect(subject.get_last_abs_resource_hosts).to eq(nil)
      end
    end
  end

  describe "#get_aws_tags" do
    context "when a pe version is specified" do
      it "returns tags including the specified role and pe version" do
        test_expected_tags = { 'role': TEST_ROLE, 'pe_version': TEST_BEAKER_PE_VERSION }

        subject.instance_variable_set(:@abs_beaker_pe_version, TEST_BEAKER_PE_VERSION)
        expect(subject.get_aws_tags(TEST_ROLE)).to eq(test_expected_tags)
      end
    end

    context "when a pe version is not specified" do
      it "returns tags that include only the specified role" do
        test_expected_tags = { 'role': TEST_ROLE }

        subject.instance_variable_set(:@abs_beaker_pe_version, nil)
        expect(subject.get_aws_tags(TEST_ROLE)).to eq(test_expected_tags)
      end
    end
  end

  describe "#get_awsdirect_request_body" do
    before do
      subject.instance_variable_set("@aws_size", TEST_SIZE)
      subject.instance_variable_set("@aws_volume_size", TEST_VOLUME_SIZE)
      subject.instance_variable_set("@aws_platform", TEST_PLATFORM)
      subject.instance_variable_set("@aws_image_id", TEST_IMAGE_ID)
      subject.instance_variable_set("@aws_region", TEST_REGION)
      subject.instance_variable_set("@aws_reap_time", TEST_REAP_TIME)
    end

    context "when a host is specified" do
      it "returns a request body for the specified host" do
        test_expected_request_body =
          { 'platform': TEST_PLATFORM,
            'image_id': TEST_IMAGE_ID,
            'size': TEST_A2A_MOM[:size],
            'region': TEST_REGION,
            'reap_time': TEST_REAP_TIME,
            'tags':
                { 'role': TEST_A2A_MOM[:role], 'pe_version': TEST_BEAKER_PE_VERSION },
            'volume_size': TEST_A2A_MOM[:volume_size] }.to_json

        expect(subject.get_awsdirect_request_body(TEST_A2A_MOM))
          .to eq(test_expected_request_body)
      end
    end
  end

  describe "#get_awsdirectreturn_request_body" do
    context "when a hostname is specified" do
      it "returns the expected result" do
        test_expected_body = { 'hostname': TEST_HOSTNAME }.to_json
        expect(subject.get_awsdirectreturn_request_body(TEST_HOSTNAME))
          .to eq(test_expected_body)
      end
    end
  end

  describe "#get_abs_token_from_fog_file" do
    context "when the .fog file exists" do
      context "when the .fog file contains the abs token" do
        it "returns the token" do
          fog_file =
            ":default:
            :abs_token: #{TEST_ABS_TOKEN}"

          expect(File).to receive(:exist?).and_return(true)
          expect(File).to receive(:read).and_return(fog_file)

          expect(subject.get_abs_token_from_fog_file).to eq(TEST_ABS_TOKEN)
        end
      end

      context "when the .fog file does not contain the abs token" do
        it "reports the error and returns nil" do
          fog_file =
            ":default:
            :not_abs_token: xyz123"

          expect(File).to receive(:exist?).and_return(true)
          expect(File).to receive(:read).and_return(fog_file)
          expect(subject).to receive(:puts).with(/ABS token not found/).at_least(:once)

          expect(subject.get_abs_token_from_fog_file).to eq(nil)
        end
      end
    end

    context "when the .fog file does not exist" do
      it "reports the error and returns nil" do
        expect(File).to receive(:exist?).and_return(false)
        expect(subject).to receive(:puts).with(/fog file not found/).at_least(:once)

        expect(subject.get_abs_token_from_fog_file).to eq(nil)
      end
    end
  end

  describe "#get_abs_token" do
    context "when a token is set as an environment variable" do
      it "returns the token" do
        ENV["ABS_TOKEN"] = TEST_ABS_TOKEN
        expect(subject.get_abs_token).to eq(TEST_ABS_TOKEN)
      end
    end

    context "when a token is not set as an environment variable" do
      context "when a token is set in the .fog file" do
        it "returns the token" do
          ENV["ABS_TOKEN"] = nil
          expect(subject).to receive(:get_abs_token_from_fog_file).and_return(TEST_ABS_TOKEN)
          expect(subject.get_abs_token).to eq(TEST_ABS_TOKEN)
        end
      end

      context "when a token is not set in the .fog file" do
        it "reports the error and returns nil" do
          ENV["ABS_TOKEN"] = nil
          expect(subject).to receive(:get_abs_token_from_fog_file).and_return(nil)
          expect(subject).to receive(:puts).with(/An ABS token must be set/)
          expect(subject.get_abs_token).to eq(nil)
        end
      end
    end
  end

  describe "#get_abs_post_request" do
    context "when an abs token is present" do
      it "returns the expected result" do
        expect(subject).to receive(:get_abs_token).and_return(TEST_ABS_TOKEN)

        stub_const("Net::HTTP::Post", test_net_http_post)
        expect(test_net_http_post).to receive(:new)
          .with(TEST_AWSDIRECT_URI, TEST_EXPECTED_REQUEST_HEADERS).and_return(test_http_request)

        expect(subject.get_abs_post_request(TEST_AWSDIRECT_URI)).to eq(test_http_request)
      end
    end

    context "when an abs token is not present" do
      it "reports the error and returns nil" do
        test_expected_message = "Unable to prepare a valid ABS request without a valid token"
        test_expected_result = nil

        expect(subject).to receive(:get_abs_token).and_return(nil)
        expect(subject).to receive(:puts).with(test_expected_message)

        expect(subject.get_abs_post_request(TEST_AWSDIRECT_URI)).to eq(test_expected_result)
      end
    end
  end

  describe "#perform_awsdirect_request" do
    context "when a request is successfully prepared" do
      it "performs the request, reports and returns the response" do
        expect(subject).to receive(:get_abs_post_request).and_return(test_http_request)
        allow(test_http_request).to receive(:body=)

        stub_const("Net::HTTP", test_net_http)
        expect(test_net_http).to receive(:new).and_return(test_net_http_instance)

        allow(test_net_http_instance).to receive(:use_ssl=)
        allow(test_net_http_instance).to receive(:read_timeout=)
        expect(test_net_http_instance).to receive(:request).with(test_http_request)
                                                           .and_return(test_http_response)

        expect(test_http_response).to receive(:code).and_return(TEST_VALID_RESPONSE_CODE)
        expect(test_http_response).to receive(:body).and_return(TEST_VALID_RESPONSE_BODY)

        allow(subject).to receive(:puts)
        expect(subject).to receive(:puts).at_least(:once)
                                         .with("response code: #{TEST_VALID_RESPONSE_CODE}")
        expect(subject).to receive(:puts).at_least(:once)
                                         .with("response body: #{TEST_VALID_RESPONSE_BODY}")

        expect(subject.perform_awsdirect_request(TEST_AWSDIRECT_URI, TEST_AWSDIRECT_REQUEST_BODY))
          .to eq(test_http_response)
      end
    end

    context "when a request is not successfully prepared" do
      it "reports the error, does not attempt the request, and returns nil" do
        test_expected_message = "Unable to complete the specified ABS request"
        test_expected_result = nil

        expect(subject).to receive(:get_abs_post_request).and_return(nil)
        expect(subject).to receive(:puts).with(test_expected_message)

        expect(subject.perform_awsdirect_request(TEST_AWSDIRECT_URI, TEST_AWSDIRECT_REQUEST_BODY))
          .to eq(test_expected_result)
      end
    end
  end

  describe "#valid_abs_response??" do
    context "when a valid response is provided" do
      it "returns true" do
        expect(test_http_response).to receive(:nil?).at_least(:once).and_return(false)
        expect(test_http_response).to receive(:code).at_least(:once)
                                                    .and_return(TEST_VALID_RESPONSE_CODE)
        expect(test_http_response).to receive(:body).at_least(:once)
                                                    .and_return(TEST_AWSDIRECT_RESPONSE_BODY)

        expect(subject.valid_abs_response?(test_http_response)).to eq(true)
      end
    end

    context "when the response is nil" do
      it "reports the error and returns false" do
        allow(subject).to receive(:puts)
        expect(subject).to receive(:puts).with(/Invalid ABS response/).at_least(:once)
        expect(subject.valid_abs_response?(nil)).to eq(false)
      end
    end

    context "when the response code is not valid" do
      # TODO: Verify the full error message including values?

      it "reports the error and returns false" do
        expect(test_http_response).to receive(:nil?).at_least(:once).and_return(false)
        expect(test_http_response).to receive(:code).at_least(:once)
                                                    .and_return(TEST_INVALID_RESPONSE_CODE)
        expect(test_http_response).to receive(:body).at_least(:once)
                                                    .and_return(TEST_AWSDIRECT_RESPONSE_BODY)

        allow(subject).to receive(:puts)
        expect(subject).to receive(:puts).with(/Invalid ABS response/)
        expect(subject).to receive(:puts).with(/code/)
        expect(subject).to receive(:puts).with(/body/)

        expect(subject.valid_abs_response?(test_http_response)).to eq(false)
      end
    end

    context "when the response body is empty" do
      it "reports the error and returns false" do
        expect(test_http_response).to receive(:nil?).at_least(:once).and_return(false)
        expect(test_http_response).to receive(:code).at_least(:once)
                                                    .and_return(TEST_VALID_RESPONSE_CODE)
        expect(test_http_response).to receive(:body).at_least(:once)
                                                    .and_return(TEST_INVALID_RESPONSE_BODY)

        allow(subject).to receive(:puts)
        expect(subject).to receive(:puts).with(/Invalid ABS response/)
        expect(subject).to receive(:puts).with(/code/)
        expect(subject).to receive(:puts).with(/body/)

        expect(subject.valid_abs_response?(test_http_response)).to eq(false)
      end
    end

    context "when the response body is nil" do
      it "reports the error and returns false" do
        expect(test_http_response).to receive(:nil?).at_least(:once).and_return(false)
        expect(test_http_response).to receive(:code).at_least(:once)
                                                    .and_return(TEST_VALID_RESPONSE_CODE)
        expect(test_http_response).to receive(:body).at_least(:once).and_return(nil)

        allow(subject).to receive(:puts)
        expect(subject).to receive(:puts).with(/Invalid ABS response/)
        expect(subject).to receive(:puts).with(/code/)
        expect(subject).to receive(:puts).with(/body/)

        expect(subject.valid_abs_response?(test_http_response)).to eq(false)
      end
    end
  end

  describe "#parse_awsdirect_response_body" do
    context "when a valid response_body is provided" do
      it "returns the expected reformatted response" do
        expect(subject.parse_awsdirect_response_body(TEST_AWSDIRECT_RESPONSE_BODY))
          .to eq(TEST_HOST)
      end
    end

    context "when an invalid response_body is provided" do
      it "reports the error and returns nil" do
        expect { subject.parse_awsdirect_response_body(TEST_INVALID_RESPONSE_BODY) }
          .to raise_error(JSON::ParserError)
      end
    end
  end

  # TODO: implement
  describe "#update_last_abs_resource_hosts" do
    context "when a host string is specified" do
      it "writes the string to the log file" do
        skip
      end
    end
  end

  # TODO: implement
  describe "#backoff_sleep" do
    context "when called with a positive number of tries" do
      it "sleeps for a multiple of the number of tries" do
        skip
      end
    end
  end

  describe "#verify_abs_host" do
    let(:test_ssh) { Class.new }
    host_key_mismatch_exception_class = Net::SSH::HostKeyMismatch

    context "when the specified number of tries has not been exceeded" do
      context "when the result is successful" do
        it "breaks and returns true" do
          stub_const("Net::SSH", test_ssh)
          test_ssh.const_set :HostKeyMismatch, host_key_mismatch_exception_class
          test_ssh_session = double
          test_ssh_result = double
          tries = 1
          result_string = "Success"

          allow(subject).to receive(:puts)
          expect(subject).to receive(:puts).with("Verifying #{TEST_HOSTNAME}")
          expect(subject).to receive(:puts).with("Attempt #{tries} for #{TEST_HOSTNAME}")

          expect(test_ssh).to receive(:start).and_return(test_ssh_session)
          expect(test_ssh_session).to receive(:exec!).and_return(test_ssh_result)
          expect(test_ssh_session).to receive(:close)

          allow(test_ssh_result).to receive(:to_s).and_return(result_string)
          expect(subject).to receive(:puts).with("Result: #{result_string}")
          expect(result_string).to receive(:include?).with("centos")

          expect(subject).not_to receive(:backoff_sleep)

          expect(subject.verify_abs_host(TEST_HOSTNAME)).to eq(true)
        end
      end

      context "when the result is an error" do
        it "reports the failure and sleeps" do
          stub_const("Net::SSH", test_ssh)
          test_ssh.const_set :HostKeyMismatch, host_key_mismatch_exception_class
          test_ssh_session = double
          test_ssh_result = double
          result_string = "Success"
          message = "Attempted connection to #{TEST_HOSTNAME} failed with 'RuntimeError'"

          allow(subject).to receive(:puts)
          expect(subject).to receive(:puts).with("Verifying #{TEST_HOSTNAME}")
          expect(subject).to receive(:puts).with("Attempt 1 for #{TEST_HOSTNAME}")
          expect(subject).to receive(:puts).with("Attempt 2 for #{TEST_HOSTNAME}")
          expect(subject).to receive(:puts).with("Attempt 3 for #{TEST_HOSTNAME}")
          expect(subject).to receive(:puts).with("Attempt 4 for #{TEST_HOSTNAME}")
          expect(subject).to receive(:puts).with("Attempt 5 for #{TEST_HOSTNAME}")
          expect(subject).to receive(:puts).with("Attempt 6 for #{TEST_HOSTNAME}")
          expect(subject).to receive(:puts).with("Attempt 7 for #{TEST_HOSTNAME}")
          expect(subject).to receive(:puts).with("Attempt 8 for #{TEST_HOSTNAME}")

          # failed attempts
          expect(test_ssh).to receive(:start)
            .exactly(7).times.and_raise(RuntimeError)

          expect(subject).to receive(:puts).with(message).exactly(7).times

          expect(subject).to receive(:backoff_sleep).exactly(7).times

          # success
          expect(test_ssh).to receive(:start)
            .exactly(1).times.and_return(test_ssh_session)

          expect(test_ssh_session).to receive(:exec!).and_return(test_ssh_result)
          expect(test_ssh_session).to receive(:close).exactly(1).times

          allow(test_ssh_result).to receive(:to_s).and_return(result_string)
          expect(subject).to receive(:puts).with("Result: #{result_string}")
          expect(result_string).to receive(:include?).exactly(1).times.with("centos")

          expect(subject.verify_abs_host(TEST_HOSTNAME)).to eq(true)
        end
      end

      context "when a host triggers a Net::SSH::HostKeyMismatch exception" do
        it "adds the host to known hosts and retries immediately" do
          stub_const("Net::SSH", test_ssh)
          test_ssh.const_set :HostKeyMismatch, host_key_mismatch_exception_class
          host_key_mismatch_exception = host_key_mismatch_exception_class.new
          test_ssh_session = double
          test_ssh_result = double
          result_string = "Success"

          allow(subject).to receive(:puts)
          expect(subject).to receive(:puts).with("Verifying #{TEST_HOSTNAME}")
          expect(subject).to receive(:puts).with("Attempt 1 for #{TEST_HOSTNAME}")

          expect(test_ssh).to receive(:start).and_raise(host_key_mismatch_exception)
          expect(host_key_mismatch_exception).to receive(:remember_host!).and_return(nil)
          expect(subject).to receive(:puts).with("Attempt 2 for #{TEST_HOSTNAME}")
          expect(test_ssh).to receive(:start).and_return(test_ssh_session)
          expect(test_ssh_session).to receive(:exec!).and_return(test_ssh_result)
          expect(test_ssh_session).to receive(:close)

          allow(test_ssh_result).to receive(:to_s).and_return(result_string)
          expect(subject).to receive(:puts).with("Result: #{result_string}")
          expect(result_string).to receive(:include?).with("centos")

          expect(subject).not_to receive(:backoff_sleep)

          expect(subject.verify_abs_host(TEST_HOSTNAME)).to eq(true)
        end
      end

      context "when the result is not successful" do
        it "reports the failure and sleeps" do
          stub_const("Net::SSH", test_ssh)
          test_ssh.const_set :HostKeyMismatch, host_key_mismatch_exception_class
          test_ssh_session = double
          test_ssh_result1 = double
          test_ssh_result2 = double
          result_string1 = "centos"
          result_string2 = "Success"
          error = "Error: root account is not yet configured"
          error_message = "Attempted connection to #{TEST_HOSTNAME} failed with '#{error}'"

          allow(subject).to receive(:puts)
          expect(subject).to receive(:puts).with("Verifying #{TEST_HOSTNAME}")
          expect(subject).to receive(:puts).with("Attempt 1 for #{TEST_HOSTNAME}")
          expect(subject).to receive(:puts).with("Attempt 2 for #{TEST_HOSTNAME}")
          expect(subject).to receive(:puts).with("Attempt 3 for #{TEST_HOSTNAME}")
          expect(subject).to receive(:puts).with("Attempt 4 for #{TEST_HOSTNAME}")
          expect(subject).to receive(:puts).with("Attempt 5 for #{TEST_HOSTNAME}")
          expect(subject).to receive(:puts).with("Attempt 6 for #{TEST_HOSTNAME}")
          expect(subject).to receive(:puts).with("Attempt 7 for #{TEST_HOSTNAME}")
          expect(subject).to receive(:puts).with("Attempt 8 for #{TEST_HOSTNAME}")

          # failed attempts
          expect(subject).to receive(:puts).with(error_message).exactly(7).times

          expect(test_ssh).to receive(:start)
            .exactly(8).times.and_return(test_ssh_session)

          expect(test_ssh_session).to receive(:exec!)
            .exactly(7).and_return(test_ssh_result1)

          expect(test_ssh_session).to receive(:close).exactly(8).times

          expect(subject).to receive(:puts).with("Result: #{result_string1}")
                                           .exactly(7).times

          allow(test_ssh_result1).to receive(:to_s).and_return(result_string1)

          expect(result_string1).to receive(:include?)
            .exactly(7).times.with("centos").and_raise(RuntimeError, error)

          expect(subject).to receive(:backoff_sleep).exactly(7).times

          # success
          expect(test_ssh_session).to receive(:exec!).and_return(test_ssh_result2)
          allow(test_ssh_result2).to receive(:to_s).and_return(result_string2)

          expect(subject).to receive(:puts).with("Result: #{result_string2}")
          expect(result_string2).to receive(:include?).with("centos")

          expect(subject.verify_abs_host(TEST_HOSTNAME)).to eq(true)
        end
      end
    end

    context "when the specified number of tries has been exceeded" do
      it "reports the failure and returns false" do
        stub_const("Net::SSH", test_ssh)
        test_ssh.const_set :HostKeyMismatch, host_key_mismatch_exception_class
        test_ssh_session = double
        error = "Error: root account is not yet configured"
        error_message = "Attempted connection to #{TEST_HOSTNAME} failed with '#{error}'"

        allow(subject).to receive(:puts)
        expect(subject).to receive(:puts).with("Verifying #{TEST_HOSTNAME}")

        expect(subject).to receive(:puts).with("Attempt 1 for #{TEST_HOSTNAME}")
        expect(subject).to receive(:puts).with("Attempt 2 for #{TEST_HOSTNAME}")
        expect(subject).to receive(:puts).with("Attempt 3 for #{TEST_HOSTNAME}")
        expect(subject).to receive(:puts).with("Attempt 4 for #{TEST_HOSTNAME}")
        expect(subject).to receive(:puts).with("Attempt 5 for #{TEST_HOSTNAME}")
        expect(subject).to receive(:puts).with("Attempt 6 for #{TEST_HOSTNAME}")
        expect(subject).to receive(:puts).with("Attempt 7 for #{TEST_HOSTNAME}")
        expect(subject).to receive(:puts).with("Attempt 8 for #{TEST_HOSTNAME}")

        expect(test_ssh).to receive(:start)
          .exactly(8).times.and_return(test_ssh_session)

        expect(test_ssh_session).to receive(:exec!)
          .exactly(8).times.and_raise(RuntimeError, error)

        expect(subject).to receive(:puts).with(error_message).exactly(8).times

        expect(subject).to receive(:backoff_sleep).exactly(8).times

        expect(test_ssh_session).not_to receive(:close)

        expect(subject).to receive(:puts).with("Failed to verify host #{TEST_HOSTNAME}")

        expect(subject.verify_abs_host(TEST_HOSTNAME)).to eq(false)
      end
    end
  end

  describe "#verify_abs_hosts" do
    context "when no hosts fail verification" do
      it "checks all hosts and returns true" do
        allow(subject).to receive(:puts)
        expect(subject).to receive(:puts).with("Verifying ABS hosts: #{TEST_ABS_HOSTS}")
        expect(subject).to receive(:puts).with("Current host: #{TEST_HOST}")

        expect(subject).to receive(:verify_abs_host)
          .with(TEST_HOSTNAME).twice.and_return(true)

        expect(subject.verify_abs_hosts(TEST_ABS_HOSTS)).to eq(true)
      end
    end

    context "when a host fails verification" do
      it "stops verifying hosts, reports the error, and returns false" do
        error = "Unable to verify the provisioned hosts"

        allow(subject).to receive(:puts)
        expect(subject).to receive(:puts).with("Verifying ABS hosts: #{TEST_ABS_HOSTS}")
        expect(subject).to receive(:puts).with("Current host: #{TEST_HOST}")

        expect(subject).to receive(:verify_abs_host)
          .with(TEST_HOSTNAME).once.and_return(false)

        expect(subject).to receive(:puts).with(error)

        expect(subject.verify_abs_hosts(TEST_ABS_HOSTS)).to eq(false)
      end
    end
  end

  describe "#valid_abs_resource_hosts?" do
    context "when a valid resource host array is specified" do
      it "returns true" do
        expect(subject.valid_abs_resource_hosts?(TEST_ABS_RESOURCE_HOSTS)).to eq(true)
      end
    end

    context "when an invalid resource host array is specified" do
      it "reports the error and returns false" do
        hosts = TEST_INVALID_ABS_RESOURCE_HOSTS
        message = "The specified resource host array is not valid: #{hosts}"
        allow(subject).to receive(:puts)
        expect(subject).to receive(:puts).with(message)

        expect(subject.valid_abs_resource_hosts?(hosts)).to eq(false)
      end
    end

    context "when an nil is specified" do
      it "reports the error and returns false" do
        allow(subject).to receive(:puts)
        expect(subject).to receive(:puts).with("A valid hosts array is required; nil was specified")

        expect(subject.valid_abs_resource_hosts?(nil)).to eq(false)
      end
    end
  end
end
