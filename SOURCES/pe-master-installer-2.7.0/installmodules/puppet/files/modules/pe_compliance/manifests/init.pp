class pe_compliance {
  # $::is_pe is a custom fact shipped with the stdlib module
  $is_pe           = str2bool($::is_pe)

  if $is_pe {
    # Include the agent class that sets up the cron job.
    anchor { 'pe_compliance::begin': }
    case $::osfamily {
      windows: {
        class { "pe_compliance::agent_windows":
          require => Anchor['pe_compliance::begin'],
          before  => Anchor['pe_compliance::end'],
        }
      }
      default: {
        class { "pe_compliance::agent":
          require => Anchor['pe_compliance::begin'],
          before  => Anchor['pe_compliance::end'],
        }
      }
    }
    anchor { 'pe_compliance::end': }
  }
}
