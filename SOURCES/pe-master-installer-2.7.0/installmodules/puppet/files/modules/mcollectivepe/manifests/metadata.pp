# Class: mcollectivepe::metadata
#
# The module is a wrapper to pe_mcollective::metadata to facilitate the ease of
# upgrade from Puppet Enterprise 1.2.x to 2.x.
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
class mcollectivepe::metadata {
  include pe_mcollective::metadata
}
