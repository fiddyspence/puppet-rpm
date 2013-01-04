# Class: accounts
#
# This is a wrapper module to the pe_accounts module to facilitate
# upgrades from Puppet Enterprise 1.2.x to 2.x. This class will pass
# off parameterized defined/declared data onto the pe_accounts class.
# Data passes transparently and we let the module/classes to handle
# and produce the errors associated with invalid data.
#
class accounts (
  $manage_groups   = true,
  $manage_users    = true,
  $manage_sudoers  = false,
  $data_store      = 'namespace',
  $data_namespace  = 'pe_accounts::data',
  $sudoers_path    = '/etc/sudoers'
) {

  # All we do here is create a new pe_accounts declaration using the data from
  # this local scope.

  class { 'pe_accounts':
    manage_groups  => $manage_groups,
    manage_users   => $manage_users,
    manage_sudoers => $manage_sudoers,
    data_store     => 'namespace',
    data_namespace => 'pe_accounts::data',
    sudoers_path   => '/etc/sudoers'
  }
}
