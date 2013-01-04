define puppet::module ($target = '/opt/puppet/share/puppet/modules') {

  file { "/opt/puppet/share/puppet/modules/${title}":
    ensure => directory,
    recurse => true,
    purge => true,
    force => true,
    source => "puppet:///modules/puppet/modules/${title}",
  }

}
