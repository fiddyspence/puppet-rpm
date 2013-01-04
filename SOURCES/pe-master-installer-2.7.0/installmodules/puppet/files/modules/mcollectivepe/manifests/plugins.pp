# Class: mcollectivepe::plugins
#
# The module is a wrapper to pe_mcollective::plugins to facilitate the ease of
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
class mcollectivepe::plugins {
  include pe_mcollective::plugins
}
