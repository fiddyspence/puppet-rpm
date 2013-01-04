
require 'lib/puppet_acceptance/dsl/install_utils'

extend PuppetAcceptance::DSL::InstallUtils

step "Linking request_manager module in to modulepath"

module_path = '/opt/puppet/share/puppet/modules'

['request_manager', 'auth_conf'].each do |module_name|
  # preserve the PE installed module (it'll get restored after the test run is complete)
  on master,
     "test -d #{module_path}/#{module_name} && mv #{module_path}/#{module_name} #{module_path}/#{module_name}.original",
     {:acceptable_exit_codes => [0, 1]}

  on master, "ln -s #{SourcePath}/#{module_name} #{module_path}"
end
