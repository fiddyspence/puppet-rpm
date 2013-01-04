# Class: accounts::user
#
# This class will pass off parameterized defined/declared data onto the
# pe_accounts::user define.  Data passes transparently and we let the
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
define accounts::user (
  $ensure     = 'present',
  $shell      = '/bin/bash',
  $comment    = $name,
  $home       = "/home/${name}",
  $uid        = undef,
  $gid        = undef,
  $groups     = [],
  $membership = 'minimum',
  $password   = '!!',
  $locked     = false,
  $sshkeys    = []
) {

  # All we do here is create a new pe_accounts::user declaration using
  # the data from this local scope.

  pe_accounts::user { $name:
    ensure     => $ensure,
    shell      => $shell,
    comment    => $comment,
    home       => $home,
    uid        => $uid,
    gid       => $gid,
    groups     => $groups,
    membership => $membership,
    password   => $password,
    locked     => $locked,
    sshkeys    => $sshkeys,
  }
}
