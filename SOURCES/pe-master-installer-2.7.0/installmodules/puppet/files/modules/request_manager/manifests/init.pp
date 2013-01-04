class request_manager {
  $is_puppetmaster  = str2bool($::fact_is_puppetmaster)
  $is_puppetconsole = str2bool($::fact_is_puppetconsole)

  if ($is_puppetmaster or $is_puppetconsole) {
    include auth_conf
    class { 'auth_conf::defaults':
      master_certname => $::fact_puppetmaster_certname,
    }

    if $is_puppetmaster {
      auth_conf::acl { '/certificate_status':
        auth       => 'yes',
        acl_method => ['find','search', 'save', 'destroy'],
        allow      => 'pe-internal-dashboard',
        order      => 085,
      }
    }

    service { 'pe-httpd':
      ensure     => running,
      subscribe  => File["/etc/puppetlabs/puppet/auth.conf"],
    }
  }
}
