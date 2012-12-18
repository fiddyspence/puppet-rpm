class install {

  File {
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    notify => Service['pe-puppet'],
  }


  file { [
    '/etc/puppetlabs/facter',
    '/etc/puppetlabs/facter/facts.d',
    ]:
    ensure => directory,
  }

  file { '/etc/puppetlabs/puppet/puppet.conf':
    ensure  => file,
    content => template('install/puppet.conf.erb'),
  }

  file { '/etc/puppetlabs/facter/facts.d/puppet_enterprise_installer.txt':
    ensure => file,
    source => 'puppet:///modules/install/puppet_enterprise_installer.txt',
  }

  file { '/var/opt/lib/pe-puppet':
    ensure  => absent,
    recurse => true,
    purge   => true,
    force   => true,
  }


  install::symlink { ['facter','gem','hiera','pe-man','puppet']: }

  service { 'pe-puppet':
    ensure => running,
    enable => true,
  }

}



