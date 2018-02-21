require 'fileutils'

test_name 'Configure Gatling SSL authorization'

# This step will generate a keystore and trustore file using the master's
# certificate and private key, and the CA's certificate.
# Sbt is be configured to look for them under simulation-runner/target/ssl.
step 'Generate Gatling SSL keystore & trustore' do
  configure_gatling_auth
end
