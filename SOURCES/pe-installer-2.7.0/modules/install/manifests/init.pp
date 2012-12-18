class install {

  $defaultpuppetsha = '0743e57d9cef7dbe89469a13b046c910cf1bdc2e'
  $currentpuppetsha = inline_template('Digest::SHA1.hexdigest File.read('/etc/puppetlabs/puppet/puppet.conf'))
  $defaultfactsha = 'b898a77b1f07f2c175c1cf089cb136de37dc18b3'
  $currentfactsha = inline_template('Digest::SHA1.hexdigest File.read('/etc/puppetlabs/facter/facts.d/puppet_enterprise_installer.txt'))

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

  if $defaultpuppetsha != $currentpuppetshafile {
    { '/etc/puppetlabs/puppet/puppet.conf':
      ensure  => file,
      content => template('install/puppet.conf.erb'),
    }
  }

  if $defaultfactsha != $currentfactsha {
    file { '/etc/puppetlabs/facter/facts.d/puppet_enterprise_installer.txt':
      ensure => file,
      source => 'puppet:///modules/install/puppet_enterprise_installer.txt',
    }
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



