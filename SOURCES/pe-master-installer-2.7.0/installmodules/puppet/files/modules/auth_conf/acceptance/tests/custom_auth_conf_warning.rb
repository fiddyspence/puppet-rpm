
test_name 'Having a modified auth.conf should show a warning and not modify auth.conf'

teardown do
  step 'Restoring auth.conf'
  on master, "cp #{AUTH_CONF_BACKUP_PATH} #{AUTH_CONF_PATH}"
end

step 'Modifying auth.conf'

on master, "echo MODIFIED >> #{AUTH_CONF_PATH}"

step 'Running manifest'

apply_manifest_on master, 'include auth_conf', {:catch_failures => true} do
  fail_test('no warning was emitted for a modified auth.conf') unless result.output.include? 'file has been manually modified. Refusing to overwrite.'
end
