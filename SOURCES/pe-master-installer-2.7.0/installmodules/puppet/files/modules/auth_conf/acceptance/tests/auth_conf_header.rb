
test_name 'An empty auth.conf should be created if the current auth.conf file is unmodified'

teardown do
  step 'Restoring auth.conf'
  on master, "cp #{AUTH_CONF_BACKUP_PATH} #{AUTH_CONF_PATH}"
end

step 'Running manifest'

apply_manifest_on master, 'include auth_conf', {:catch_failures => true} do
  fail_test('auth.conf should not be modified') if result.output.include? 'file has been manually modified. Refusing to overwrite.'
end

on master, "md5sum #{AUTH_CONF_PATH}" do
  fail_test('unexpected auth.conf content, should just be the header') unless result.output.include? '91b074a7a44b3048dd3126bca71e2eb8'
end