class puppet::ca {

  exec { "/opt/puppet/bin/puppet cert --generate ${fqdn} --dns_alt_names '${hostname},${fqdn},puppet,puppet.${domain}' --verbose --color=false|| true": 
    creates => '/etc/puppetlabs/puppet/ssl/ca/signed/centos62.spence.org.uk.local.pem',
  }

}
