require 'puppet/gatling/config'
require 'fileutils'

test_name 'Configure Gatling SSL authorization'

# This step will generate a keystore and trustore file using the master's
# certificate and private key, and the CA's certificate.
# Sbt is be configured to look for them under simulation-runner/target/ssl.
step 'Generate Gatling SSL keystore & trustore' do
  # Make room for local copies
  ssldir = ENV['PWD'] + '/../simulation-runner/target/ssl'
  FileUtils.rm_rf(ssldir)
  FileUtils.mkdir_p(ssldir)

  # Copy over master's cert
  mastercert = on(master, puppet('config print hostcert')).stdout.chomp
  scp_from(master, mastercert, ssldir)
  FileUtils.mv(File.join(ssldir, File.basename(mastercert)),
               File.join(ssldir, 'mastercert.pem'))

  # Copy over master's private key
  masterkey = on(master, puppet('config print hostprivkey')).stdout.chomp
  scp_from(master, masterkey, ssldir)
  FileUtils.mv(File.join(ssldir, File.basename(masterkey)),
               File.join(ssldir, 'masterkey.pem'))

  # Copy over CA's cert
  cacert = on(master, puppet('config print localcacert')).stdout.chomp
  scp_from(master, cacert, ssldir)
  FileUtils.mv(File.join(ssldir, File.basename(cacert)),
               File.join(ssldir, 'cacert.pem'))

  # Generate keystore
  master_certname = on(master, puppet('config print certname')).stdout.chomp
  %x{cat #{ssldir}/mastercert.pem #{ssldir}/masterkey.pem > #{ssldir}/keystore.pem}
  %x{echo "puppet" | openssl pkcs12 -export -in #{ssldir}/keystore.pem -out #{ssldir}/keystore.p12 -name #{master_certname} -passout fd:0}
  %x{keytool -importkeystore -destkeystore #{ssldir}/gatling-keystore.jks -srckeystore #{ssldir}/keystore.p12 -srcstoretype PKCS12 -alias #{master_certname} -deststorepass "puppet" -srcstorepass "puppet"}

  # Generate truststore
  %x{keytool -import -alias "CA" -keystore #{ssldir}/gatling-truststore.jks -storepass "puppet" -trustcacerts -file #{ssldir}/cacert.pem -noprompt}
end
