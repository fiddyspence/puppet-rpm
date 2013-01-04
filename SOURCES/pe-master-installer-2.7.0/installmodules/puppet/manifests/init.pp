class puppet {

  class { '::puppet::params': } ->
  class { '::puppet::facts': } ->
  class { '::puppet::files': } ->
  class { '::puppet::mysql': } ->
  puppet::module { $puppet::params::modules: } ->
  class { '::puppet::requestmanager': } ->
  class { '::puppet::ca': }
#  Class['puppet']
  
}
