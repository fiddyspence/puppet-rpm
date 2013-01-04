# MCollective Puppet Enterprise
#
# This module manages the initial configuration of MCollective for use with
# Puppet Enterprise.  The primary purpose is to generate RSA key pairs for the
# initial "peadmin" user account on the Puppet Master and a shared set of RSA keys
# for all of the MCollective server processes (Puppet Agent roles).
#
# Resources managed on a Puppet Master:
#
#  * peadmin user account
#  * RSA keys to identify and authorize the peadmin user.
#  * One set of RSA keys generated for shared use among all MCollective agents.
#
# Resources managed on a Puppet Agent:
#
#  * RSA keys for MCollective service
#  * peadmin user account public RSA key to authenticate the peadmin user
#
# == Parameters
#
# This class expects four facts to be provided:
#
#  * fact_is_puppetmaster (true/false)
#  * fact_is_puppetagent  (true/false)
#  * fact_stomp_server    (hostname)
#  * fact_stomp_port      (TCP port number)
#
# The facts are automatically set by the Puppet Enterprise installer for each
# system.
#
# This class defaults to the "psk" security provider.  You may
# optionally specify the "aespe_security" security provider by setting the
# $::mcollective_security_provider variable in the Puppet Dashboard or as a
# custom fact.
#
# If a pre-shared-key is used, a randomly generated string (The contents of the
# mcollective credientials file) with be fed into the SHA1 hash algorithm to
# produce a unique key.
#
# This module will automatically setup up openwire network connectors for all
# brokers you indicate.  To do this you can either set an array using the
# parameters or from within the Console set activemq_brokers to a comma
# seperated list and the module with do the correct thing.
#
class pe_mcollective(
  $activemq_heap_mb = 'UNSET',
  $activemq_brokers = 'UNSET'
) {
  # #10961 This variable is used by the activemq-wrapper.conf template to set
  # the initial and maximum java heap size.  The value is looked up in the
  # class parameter, then the global scope so it may be set as a Fact or Node
  # Parameter.
  $activemq_heap_mb_real = $activemq_heap_mb ? {
    'UNSET' => $::activemq_heap_mb ? {
      undef   => '512',
      default => $::activemq_heap_mb,
    },
    default => $activemq_heap_mb,
  }
  validate_re($activemq_heap_mb_real, '^[0-9]+$',
      "The activemq_heap_mb parameter must be a number, e.g. 1024.  We got: [${activemq_heap_mb_real}]")

  # Stomp SSL Support
  # Turned on by default.
  $mcollective_enable_stomp_ssl = $::mcollective_enable_stomp_ssl ? {
    'true'  => true,
    'false' => false,
    undef   => true,
    ''      => true,
    default => $::mcollective_enable_stomp_ssl,
  }
  validate_bool($mcollective_enable_stomp_ssl)
  # This variable is used by the ActiveMQ template.
  $stomp_activemq_protocol = $mcollective_enable_stomp_ssl ? {
    true  => 'stomp+ssl',
    false => 'stomp+nio',
  }
  # This variable is used by the ActiveMQ template for clustering.
  $openwire_activemq_protocol = $mcollective_enable_stomp_ssl ? {
    true  => 'ssl',
    false => 'tcp',
  }

  # The default mcollective security provider.  Change this variable if the
  # default changes as a result of Product's decision.
  $mcollective_security_provider_default = 'psk'

  $stomp_server = $::fact_stomp_server ? {
    undef   => 'puppetmaster',
    default => $::fact_stomp_server,
  }
  $stomp_port = $::fact_stomp_port ? {
    undef   => '61613',
    default => $::fact_stomp_port,
  }

  # #12210 Sets up openwire connectors for replicating messages across all
  # brokers.  The class parameter takes precedence over the topscope variable.
  $activemq_brokers_real = $activemq_brokers ? {
    'UNSET' => split($::activemq_brokers, ','),
    default => $activemq_brokers,
  }

  # Variables used by ERB templates.  This may be dynamically generated in the future.
  $stomp_user                   = 'mcollective'
  $stomp_password_file_contents = file('/etc/puppetlabs/mcollective/credentials')
  # Only take the first line as the password. Editors leave trailing newlines.
  $stomp_password_array         = split($stomp_password_file_contents, '\n')
  $stomp_password               = $stomp_password_array[0]

  # Pre-Shared Key for MCollective
  $mcollective_psk_string       = sha1($stomp_password_file_contents)
  # Determine the MCollective Security Model
  $mcollective_security_provider  = $::mcollective_security_provider ? {
    undef   => $mcollective_security_provider_default,
    default => $::mcollective_security_provider,
  }
  # We only support two security providers for the time being.
  validate_re($mcollective_security_provider, '^psk$|^aespe_security$',
      "The mcollective_security_provider parameter must be 'psk' or 'aespe_security'.  We got: [$mcollective_security_provider]")

  # $::is_pe is a custom fact shipped with the stdlib module
  $is_pe = str2bool($::is_pe)

  # (#8826) Manage the plugins for MCollective in Puppet Enterprise
  # The anchors are to gurantee resource containment for the module
  anchor { 'pe_mcollective::begin': }
  if $is_pe and $::osfamily == 'Windows' {
    # Do nothing on windows
  } elsif $is_pe {
    # Convert facter strings to booleans
    $is_puppetmaster = $::fact_is_puppetmaster ? { 'true'  => true, 'false' => false }
    $is_puppetconsole = $::fact_is_puppetconsole ? { 'true'  => true, 'false' => false }
    $is_puppetagent = $::fact_is_puppetagent ? { 'true'  => true, 'false' => false }

    class { 'pe_mcollective::posix':
      require => Anchor['pe_mcollective::begin'],
      before  => Anchor['pe_mcollective::end'],
    }
    class { 'pe_mcollective::plugins':
      require => Anchor['pe_mcollective::begin'],
      before  => Anchor['pe_mcollective::end'],
    }
    # (#9045) Update facter facts on disk periodically using a cron job.
    # This is a separate class because I'm anticipating platform oddities
    # with cron on different platforms.
    class { 'pe_mcollective::metadata':
      require => Anchor['pe_mcollective::begin'],
      before  => Anchor['pe_mcollective::end'],
    }
  } else {
    # Allow users to disable this notification
    if ! $::warn_on_nonpe_agents {
      notify { 'pe_mcollective-un_supported_platform':
        message  => "${::clientcert} (osfamily = ${::osfamily}) is not a Puppet Enterprise agent. It will not appear when using the mco command-line tool or from within Live Management in the Puppet Enterprise Console. \n You may voice your opinion on PE platform support here: http://links.puppetlabs.com/puppet_enterprise_2.x_platform_support \n If you no longer wish to see this message for all non-PE agents, visit your Puppet Enterprise Console and create the parameter warn_on_nonpe_agents (key) to false (value) in the default group. ",
      }
    }
  }
  anchor { 'pe_mcollective::end': }
}
