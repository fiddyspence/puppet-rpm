# Class: accounts::groups
#
# This class will pass off parameterized defined/declared data onto the
# pe_accounts:groups class.  Data passes transparently and we let the
# module/classes to handle and produce the errors associated with invalid data.
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
class accounts::groups (
  $groups_hash
) {

  # All we do here is create a new pe_accounts::groups declaration using the
  # data from this local scope.

  class { 'pe_accounts::groups':
    groups_hash => $groups_hash
  }
}
