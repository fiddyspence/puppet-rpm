# Class: accounts::manage_keys
#
# This class will pass off parameterized defined/declared data onto the
# pe_accounts::manage_keys define.  Data passes transparently and we let the
# module/classes handle and produce the errors associated with invalid data.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
# [Remember: No empty lines between comments and class definition]
define accounts::manage_keys (
  $user,
  $key_file
) {

  # All we do here is create a new pe_accounts::manage_keys declaration using
  # the data from this local scope.

  pe_accounts::manage_keys { $name:
    user     => $user,
    key_file => $key_file
  }
}
