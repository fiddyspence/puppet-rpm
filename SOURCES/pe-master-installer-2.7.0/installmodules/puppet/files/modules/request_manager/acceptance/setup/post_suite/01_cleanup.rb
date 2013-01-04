
step "Cleaning up modulepath symlink"

module_path = '/opt/puppet/share/puppet/modules'

['request_manager', 'auth_conf'].each do |module_name|
  on master, "readlink #{module_path}/#{module_name} && rm #{module_path}/#{module_name}"

  on master,
     "test -d #{module_path}/#{module_name}.original && mv #{module_path}/#{module_name}.original #{module_path}/#{module_name}",
     {:acceptable_exit_codes => [0, 1]}
end