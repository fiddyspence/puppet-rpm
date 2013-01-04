# Class: accounts::home_dir
#
# This class will pass off parameterized defined/declared data onto the
# pe_accounts::home_dir define.  Data passes transparently and we let the
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
define accounts::home_dir (
  $user,
  $sshkeys = []
) {

  # All we do here is create a new pe_accounts::home_dir declaration using the
  # data from this local scope.

  pe_accounts::home_dir { $name:
    user    => $user,
    sshkeys => $sshkeys,
  }
}
