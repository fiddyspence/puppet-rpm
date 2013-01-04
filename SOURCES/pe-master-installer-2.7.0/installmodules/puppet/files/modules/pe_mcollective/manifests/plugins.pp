# Class: pe_mcollective::plugins
#
# This class manages the security plugin for MCollective in Puppet Enterprise.
#
# This class is meant to be declared from the main pe_mcollective class and
# should not be declared directly by the end user of Puppet Enterprise.
#
# In addition, the class also deploys all of the supported MCollective plugins shipped
# as part of Puppet Enterprise.
#
class pe_mcollective::plugins(
  $plugin_basedir='/opt/puppet/libexec/mcollective/mcollective'
) {

  # Class parameter validation
  validate_re($plugin_basedir, '^/') # fully qualified path

  File {
    owner  => '0',
    group  => '0',
    mode   => '0644',
    notify => Service['mcollective']
  }

  # Convenience variable
  $s_uri = "puppet:///modules/${module_name}/plugins"

  # Security directory
  file { "${plugin_basedir}/security": ensure => directory }
  # Modified AES Security Plugin with replay protection
  file { "${plugin_basedir}/security/aespe_security.rb":
    source => "${s_uri}/security/aespe_security.rb",
  }
  # sshkey
  file { "${plugin_basedir}/security/sshkey.rb":
    source => "${s_uri}/security/sshkey.rb",
  }

  # (#8826) Plugins for PE
  file { "${plugin_basedir}/agent": ensure => directory }
  # Puppet RAL
  file { "${plugin_basedir}/agent/puppetral.ddl":
    source => "${s_uri}/agent/puppetral.ddl",
  }
  file { "${plugin_basedir}/agent/puppetral.rb":
    source => "${s_uri}/agent/puppetral.rb",
  }
  # Package
  file { "${plugin_basedir}/agent/package.ddl":
    source => "${s_uri}/agent/package.ddl",
  }
  file { "${plugin_basedir}/agent/package.rb":
    source => "${s_uri}/agent/package.rb",
  }
  file { "${plugin_basedir}/application/package.rb":
    source => "${s_uri}/application/package.rb",
  }
  # service
  file { "${plugin_basedir}/agent/service.ddl":
    source => "${s_uri}/agent/service.ddl",
  }
  file { "${plugin_basedir}/agent/service.rb":
    source => "${s_uri}/agent/service.rb",
  }
  file { "${plugin_basedir}/application/service.rb":
    source => "${s_uri}/application/service.rb",
  }
  # puppetd
  file { "${plugin_basedir}/agent/puppetd.ddl":
    source => "${s_uri}/agent/puppetd.ddl",
  }
  file { "${plugin_basedir}/agent/puppetd.rb":
    source => "${s_uri}/agent/puppetd.rb",
  }
  file { "${plugin_basedir}/application/puppetd.rb":
    source => "${s_uri}/application/puppetd.rb",
  }
  # Registration
  file { "${plugin_basedir}/registration":
    ensure => directory,
  }
  # Registration meta plugin
  file { "${plugin_basedir}/registration/meta.rb":
    source => "${s_uri}/registration/meta.rb",
  }
  # Util plugins (Mainly for RPC Authorization)
  file { "${plugin_basedir}/util":
    ensure => directory,
    mode   => 0755,
  }
  # RPC Authorization
  # We enable RPC authorization, but leave the default to be wide open.
  # This will allow end users to add policy files if they wish.
  file { "${plugin_basedir}/util/actionpolicy.rb":
    source => "${s_uri}/util/actionpolicy.rb",
  }
}
