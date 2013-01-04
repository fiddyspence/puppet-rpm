
test_name 'An auth.conf with 0644 permissions should be created if the current auth.conf file is unmodified'

teardown do
  step 'Restoring auth.conf'
  on master, "chmod 0644 #{AUTH_CONF_PATH}"
end

step 'Changing auth.conf permissions'

on master, "chmod 0600 #{AUTH_CONF_PATH}"

step 'Running manifest'

apply_manifest_on master, 'include auth_conf', {:catch_failures => true} do
  fail_test('auth.conf should not be modified') if result.output.include? 'file has been manually modified. Refusing to overwrite.'

  fail_test('auth.conf ended up with the wrong permissions') unless result.output.include? "mode changed '0600' to '0644'"
end