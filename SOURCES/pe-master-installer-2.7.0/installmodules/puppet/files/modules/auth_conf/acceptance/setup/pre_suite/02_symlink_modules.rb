
require 'lib/puppet_acceptance/dsl/install_utils'

extend PuppetAcceptance::DSL::InstallUtils

step "Linking auth_conf module in to modulepath"

module_path = '/opt/puppet/share/puppet/modules'

# preserve the PE installed module (it'll get restored after the test run is complete)
on master,
   "test -d #{SourcePath}/auth_conf && mv #{module_path}/auth_conf #{module_path}/auth_conf.original",
   {:acceptable_exit_codes => [0, 1]}

on master, "ln -s #{SourcePath}/auth_conf #{module_path}"