class puppet::facts {
  file { ['/etc/puppetlabs/facter','/etc/puppetlabs/facter/facts.d']:
    ensure => directory,
    owner => 'root',
    group => 'root',
    mode  => '0755',
  }

  file { '/etc/puppetlabs/facter/puppet_enterprise_installer.txt':
    ensure => file,
    content => "fact_stomp_port=61613\nact_stomp_server=${fqdn}\nfact_is_puppetagent=true\nfact_is_puppetmaster=true\nfact_is_puppetca=true\nfact_is_puppetconsole=true\nfact_puppetmaster_certname=${fqdn}",
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }
}