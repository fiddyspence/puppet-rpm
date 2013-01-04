
test_name 'A certificate_status end point should be created on the puppet master'

teardown do
  step 'Restoring auth.conf'
  on master, "cp #{AUTH_CONF_BACKUP_PATH} #{AUTH_CONF_PATH}"
end

step 'Running manifest'

apply_manifest_on master, 'include request_manager', {:catch_failures => true} do
  fail_test('auth.conf should not be modified') if result.output.include? 'file has been manually modified. Refusing to overwrite.'

  fail_test('httpd did not restart') unless result.output.include? "Service[pe-httpd]: Triggered 'refresh'"
end

step 'Checking for default master end points and master certificate name'

master_certname = on dashboard, facter('-p', 'fact_puppetmaster_certname')
master_certname = master_certname.stdout.strip

# "allow master" will only appear in the facts stanza on the console
on dashboard, "grep 'allow #{master_certname}' #{AUTH_CONF_PATH}"

step 'Checking for certificate_status end point'

on master, "grep /certificate_status #{AUTH_CONF_PATH}"
