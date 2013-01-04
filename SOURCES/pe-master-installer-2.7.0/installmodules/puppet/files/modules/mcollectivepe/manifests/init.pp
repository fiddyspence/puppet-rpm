# Class: mcollectivepe
#
# This module is a wrapper to the pe_mcollective module to facilitate upgrades from
# Puppet Enterprise 1.2.x to 2.x. See the pe_mcollective module for additional
# information.
#
class mcollectivepe {
  include pe_mcollective
}
