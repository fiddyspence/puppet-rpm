
test_name 'An default auth.conf should be created if the current auth.conf file is unmodified and auth_conf::defaults are included'

teardown do
  step 'Restoring auth.conf'
  on master, "cp #{AUTH_CONF_BACKUP_PATH} #{AUTH_CONF_PATH}"
end

step 'Running manifest'

apply_manifest_on master, 'include auth_conf::defaults', {:catch_failures => true} do
  fail_test('auth.conf should not be modified') if result.output.include? 'file has been manually modified. Refusing to overwrite.'
end

on master, "md5sum #{AUTH_CONF_PATH}" do
  fail_test('unexpected auth.conf content, should be the full default config') unless result.output.include? '305d544f97712c81b646b98728a51800 '
end
