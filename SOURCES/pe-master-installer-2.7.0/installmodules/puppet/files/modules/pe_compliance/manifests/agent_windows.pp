# = Class: pe_compliance::agent_windows
#
#   This class manages a scheduled task to run `puppet inspect` periodically.
#   This class is meant to be declared from the pe_compliance class.  It should
#   not be included in a node classification.
#
# = Parameters
#
# = Actions
#
# = Requires
#
# = Sample Usage
#
#   This class will be included in the catalog of windows nodes if the
#   pe_compliance class is declared.
#
# (MARKUP: http://links.puppetlabs.com/puppet_manifest_documentation)
class pe_compliance::agent_windows {
  # $::env_windows_installdir is expected to be a Facter fact.
  $node_installdir = $::env_windows_installdir
  # $::puppet_vardir is expected to be a Facter fact.
  $node_vardir     = $::puppet_vardir

  # Abort catalog compilation if we didn't get an absolute path
  validate_absolute_path($node_installdir)
  validate_absolute_path($node_vardir)

  File {
    owner => 'Administrators',
    group => 'SYSTEM',
    mode  => '0770',
  }

  file { 'pe_compliance':
    ensure => directory,
    path   => "${node_vardir}/pe_compliance",
  }

  # This file is a wrapper script to set the PATH
  file { 'pe_compliance puppet_inspect_wrapper':
    ensure  => file,
    path    => "${node_vardir}/pe_compliance/puppet_inspect_wrapper.cmd",
    content => template("${module_name}/puppet_inspect_wrapper.cmd.erb"),
  }

  $task_trigger = {
    schedule   => daily,
    every      => 1,
    start_date => '2010-1-1',
    start_time => '20:00',
  }

  $task_command = "${node_vardir}/pe_compliance/puppet_inspect_wrapper.cmd"
  $task_command_path = inline_template('<%= task_command.gsub(/\//, "\\") %>')

  scheduled_task { 'PuppetInspect':
    ensure  => present,
    enabled => true,
    command => $task_command_path,
    trigger => $task_trigger,
    require => File['pe_compliance puppet_inspect_wrapper'],
  }
}
