class puppet::files {
  File {
    owner => 'pe-puppet',
    group => 'pe-puppet',
  }
  file { '/etc/puppetlabs/puppet/puppet.conf':
    ensure  => file,
    mode    => '0600',
    content => template('puppet/puppet.conf.erb'),
  }
  file { '/etc/puppetlabs/puppet/auth.conf':
    ensure  => file,
    mode    => '0600',
    content => template('puppet/auth.conf.erb'),
  }
  file { '/opt/puppet/share/puppet/modules':
    ensure  => directory,
    recurse => true,
    force   => true,
  }

  file { ['/var/opt','/var/opt/lib']:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
  }

  file { [
    '/var/opt/lib/pe-puppetmaster/public/',
    '/var/opt/lib/pe-puppetmaster/public/tmp',
    '/var/opt/lib/pe-puppet',
    ]:
    ensure => directory,
  }

}
