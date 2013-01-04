class puppet::requestmanager {

  exec { '/opt/puppet/bin/puppet apply --no-report --modulepath /opt/puppet/share/puppet/modules -v --exec "class { request_manager: }"': }

}
