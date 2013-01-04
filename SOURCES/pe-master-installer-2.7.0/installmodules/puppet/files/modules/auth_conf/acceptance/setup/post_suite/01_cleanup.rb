
step "Cleaning up modulepath symlink"

module_path = '/opt/puppet/share/puppet/modules'

on master, "readlink #{module_path}/auth_conf && rm #{module_path}/auth_conf"

on master,
   "test -d #{module_path}/auth_conf.original && mv #{module_path}/auth_conf.original #{module_path}/auth_conf",
   {:acceptable_exit_codes => [0, 1]}