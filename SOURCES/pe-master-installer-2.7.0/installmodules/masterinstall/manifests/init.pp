class masterinstall {

  $puppetconf = '/etc/puppetlabs/puppet/puppet.conf'
  $factsdfile = '/etc/puppetlabs/facter/facts.d/puppet_enterprise_installer.txt'

  $defaultpuppetsha = '0743e57d9cef7dbe89469a13b046c910cf1bdc2e'
  $currentpuppetsha = inline_template("<%= Digest::SHA1.hexdigest(File.read(@puppetconf)) if File.exists?(@puppetconf) -%>")
  $defaultfactsha = 'b898a77b1f07f2c175c1cf089cb136de37dc18b3'
  $currentfactsha = inline_template("<%= Digest::SHA1.hexdigest(File.read(@factsdfile)) if File.exists?(@factsdfile) -%>")

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

  if ($defaultpuppetsha == $currentpuppetsha) or ( $currentpuppetsha == '') {
    file { '/etc/puppetlabs/puppet/puppet.conf':
      ensure  => file,
      content => template('install/puppet.conf.erb'),
      owner   => 'pe-puppet',
      group   => 'pe-puppet',
      mode    => '0600',
    }
  }

  if ( $defaultfactsha == $currentfactsha ) or ( $currentfactsha == '' ){
    file { '/etc/puppetlabs/facter/facts.d/puppet_enterprise_installer.txt':
      ensure => file,
      source => 'puppet:///modules/masterinstall/puppet_enterprise_installer.txt',
      mode   => '0644',
    }
  }

  masterinstall::symlink { ['facter','gem','hiera','pe-man','puppet']: }

  service { 'pe-puppet':
    ensure => running,
    enable => true,
  }

}



