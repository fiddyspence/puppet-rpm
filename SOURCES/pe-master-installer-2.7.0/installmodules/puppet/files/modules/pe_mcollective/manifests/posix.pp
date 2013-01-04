# = Class: pe_mcollective::posix
#
#   This class manages the configuration of MCollective in Puppet Enterprise
#   for POSIX operating systems.  In reality this means everything except
#   Microsoft Windows.  A separate class will manage MCollective's
#   configuration on non-posix like operating systems.
#
#   This class is meant to be declared from the pe_mcollective class and should
#   not be part of a node definition.
#
# = Parameters
#
# = Actions
#
# = Requires
#
#   Class[pe_mcollective]
#
# = Sample Usage
#
# This class will automatically be included in the catalog if necessary.
#
#     include pe_mcollective
#
class pe_mcollective::posix {
  $activemq_heap_mb_real = $pe_mcollective::activemq_heap_mb_real

  validate_re($::fact_is_puppetmaster, '^true$|^false$',
      "The fact named fact_is_puppetmaster is not 'true' or 'false'.  It is currently set to: [${::fact_is_puppetmaster}].  A common cause of this problem is running puppet agent as a normal user instead of root or the facts missing from /etc/puppetlabs/facter/facts.d/puppet_installer.txt.  This fact is required.  This UUID should help Google find this error: 33633615-894A-415A-B728-F4D5EC5D2B25")
  validate_re($::fact_is_puppetconsole, '^true$|^false$',
      "The fact named fact_is_puppetconsole is not 'true' or 'false'.  It is currently set to: [${::fact_is_puppetconsole}].  A common cause of this problem is running puppet agent as a normal user instead of root or the facts missing from /etc/puppetlabs/facter/facts.d/puppet_installer.txt.  This fact is required.  This UUID should help Google find this error: 175EE640-6998-44EB-903A-51261F2ABA43")
  validate_re($::fact_is_puppetagent, '^true$|^false$',
      "The fact named fact_is_puppetagent is not 'true' or 'false'.  It is currently set to: [${::fact_is_puppetagent}].  A common cause of this problem is running puppet agent as a normal user instead of root or the facts missing from /etc/puppetlabs/facter/facts.d/puppet_installer.txt.  This fact is required.  This UUID should help Google find this error: BCED2C08-418F-433B-A8B7-7CEFBD050E1C")
  validate_re($::fact_stomp_server, '^[a-zA-Z0-9.-]+$',
      "The fact named fact_stomp_server does not appear to be a valid hostname.  The value of '${::fact_stomp_server}' does not match '^[a-zA-Z0-9.-]+$'.  A common cause of this problem is running puppet agent as a normal user instead of root or the facts missing from /etc/puppetlabs/facter/facts.d/puppet_installer.txt.  This fact is required.  This UUID should help Google find this error: CA149CCB-0F9E-4208-BC29-18E3AF07CADF")
  validate_re($::fact_stomp_port, '^[0-9]+$',
      "The fact named fact_stomp_port is not numeric.  It is currently set to: [${::fact_stomp_port}].  A common cause of this problem is running puppet agent as a normal user instead of root or the facts missing from /etc/puppetlabs/facter/facts.d/puppet_installer.txt.  This fact is required.  This UUID should help Google find this error: 72F6395D-6FB3-4970-8300-3BC6149ECA08")

  # JJM This is here to work around the unlikely event that $::fqdn is an empty string.
  # See: http://goo.gl/hVm0r
  $fqdn_real = $::fqdn ? {
    undef   => $::hostname,
    ''      => $::hostname,
    default => $::fqdn,
  }

  # This resource default is here to help improve troubleshooting of failures
  Exec {
    logoutput => on_failure
  }

  if $pe_mcollective::is_puppetmaster {
    # Make sure ActiveMQ is running on the master.
    service { 'pe-activemq':
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
      require => [ File['/etc/puppetlabs/activemq/activemq.xml'] ],
    }
    # Make sure activemq is aware of the stomp password
    file { "/etc/puppetlabs/activemq/activemq.xml":
      ensure  => file,
      content => template("${module_name}/activemq.xml.erb"),
      owner   => '0',
      group   => 'pe-activemq',
      mode    => '0640',
      notify => [ Service['pe-activemq'] ],
    }
    # Configure the ActiveMQ Wrapper in case we've enabled SSL
    file { "/etc/puppetlabs/activemq/activemq-wrapper.conf":
      ensure  => file,
      content => template("${module_name}/activemq-wrapper.conf.erb"),
      owner   => '0',
      group   => '0',
      mode    => '0644',
      notify  => [ Service['pe-activemq'] ],
    }
    file { "credentials":
      path    => '/etc/puppetlabs/mcollective/credentials',
      owner   => 'pe-puppet',
      group   => 'pe-puppet',
      mode    => '0600',
    }

    # Make sure we have a shared certificate for all of the MC servers
    exec { 'mcollective-server-cert':
      command => 'puppet cert --generate pe-internal-mcollective-servers',
      path    => '/opt/puppet/bin:/usr/kerberos/sbin:/usr/kerberos/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
      creates => '/etc/puppetlabs/puppet/ssl/certs/pe-internal-mcollective-servers.pem',
      before  => [ File['mcollective-public.pem'], File['mcollective-private.pem'], File['mcollective-cert.pem'] ],
    }
    exec { 'mcollective-client-cert':
      command => 'puppet cert --generate pe-internal-peadmin-mcollective-client',
      path    => '/opt/puppet/bin:/usr/kerberos/sbin:/usr/kerberos/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
      creates => '/etc/puppetlabs/puppet/ssl/certs/pe-internal-peadmin-mcollective-client.pem',
      before  => [ File['peadmin-public.pem'] ]
    }
    exec { 'puppet-dashboard-client-cert':
      command => 'puppet cert --generate pe-internal-puppet-console-mcollective-client',
      path    => '/opt/puppet/bin:/usr/kerberos/sbin:/usr/kerberos/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
      creates => '/etc/puppetlabs/puppet/ssl/certs/pe-internal-puppet-console-mcollective-client.pem',
      before  => [ File['puppet-dashboard-public.pem'] ]
    }

    # Generate the SSL Certificate used by the Stomp Server if SSL is enabled.
    if $pe_mcollective::mcollective_enable_stomp_ssl {
      # We use Puppet's CA to generate the private key and issue the certificate
      exec { 'broker_cert':
        command => "bash -c 'puppet cert --generate pe-internal-broker --dns_alt_names 'stomp,${pe_mcollective::stomp_server},${fqdn_real}' && test -f /etc/puppetlabs/puppet/ssl/ca/signed/pe-internal-broker.pem'",
        path    => '/opt/puppet/bin:/usr/kerberos/sbin:/usr/kerberos/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
        creates => '/etc/puppetlabs/puppet/ssl/ca/signed/pe-internal-broker.pem',
        notify  => [ Exec['broker_cert_bundle'] ],
      }
      # We need to combine the artifacts in order to covert to PKCS12
      exec { 'broker_cert_bundle':
        command => "sh -c 'umask 077; cat /etc/puppetlabs/puppet/ssl/private_keys/pe-internal-broker.pem /etc/puppetlabs/puppet/ssl/ca/signed/pe-internal-broker.pem /etc/puppetlabs/puppet/ssl/certs/ca.pem > /etc/puppetlabs/activemq/broker.pem'",
        path    => '/opt/puppet/bin:/usr/kerberos/sbin:/usr/kerberos/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
        creates => '/etc/puppetlabs/activemq/broker.pem',
        before  => [ File['/etc/puppetlabs/activemq/broker.pem'] ],
      }
      file { '/etc/puppetlabs/activemq/broker.pem':
        ensure => file,
        owner  => '0',
        group  => '0',
        mode   => '0600',
      }
      # Now convert the bundle to a PKCS12 format file
      exec { 'broker_cert_pkcs12':
        command => "sh -c 'umask 077; openssl pkcs12 -export -in broker.pem -out broker.p12 -name ${pe_mcollective::stomp_server} -passout pass:puppet'",
        cwd     => '/etc/puppetlabs/activemq',
        path    => '/opt/puppet/bin:/usr/kerberos/sbin:/usr/kerberos/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
        creates => '/etc/puppetlabs/activemq/broker.p12',
        require => [ File['/etc/puppetlabs/activemq/broker.pem'] ],
        before  => [ File['/etc/puppetlabs/activemq/broker.p12'] ],
      }
      file { '/etc/puppetlabs/activemq/broker.p12':
        ensure => file,
        owner  => '0',
        group  => '0',
        mode   => '0600',
      }
      # Now convert the PKCS12 format file into a Java Key Store
      exec { 'broker_cert_keystore':
        command => "sh -c 'umask 077; keytool -importkeystore -deststorepass puppet -destkeypass puppet -destkeystore broker.ks -srckeystore broker.p12 -srcstorepass puppet -srcstoretype PKCS12 -alias ${pe_mcollective::stomp_server}'",
        cwd     => '/etc/puppetlabs/activemq',
        path    => '/opt/puppet/bin:/usr/kerberos/sbin:/usr/kerberos/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
        creates => '/etc/puppetlabs/activemq/broker.ks',
        require => [ File['/etc/puppetlabs/activemq/broker.p12'] ],
        before  => [ File['/etc/puppetlabs/activemq/broker.ks'] ],
      }
      file { '/etc/puppetlabs/activemq/broker.ks':
        ensure => file,
        owner   => '0',
        group   => 'pe-activemq',
        mode    => '0640',
        notify => [ Service['pe-activemq'] ],
      }
      # Finally, create the Java TrustStore file.  This isn't required on some JVM's, but it
      # is with the IBM JVM.  If the file does not exist ActiveMQ will fail to start.
      exec { 'broker_cert_truststore':
        command => "sh -c 'umask 077; keytool -import -noprompt -trustcacerts -alias 'PuppetCA' -file /etc/puppetlabs/puppet/ssl/certs/ca.pem -keystore broker.ts -storepass puppet'",
        cwd     => '/etc/puppetlabs/activemq',
        path    => '/opt/puppet/bin:/usr/kerberos/sbin:/usr/kerberos/bin:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin',
        creates => '/etc/puppetlabs/activemq/broker.ts',
        before  => [ File['/etc/puppetlabs/activemq/broker.ts'] ],
      }
      file { '/etc/puppetlabs/activemq/broker.ts':
        ensure => file,
        owner   => '0',
        group   => 'pe-activemq',
        mode    => '0640',
        notify => [ Service['pe-activemq'] ],
      }
    }
  }

  # Configure the AES keys on each mcollective server (Note, these are not
  # actually used as SSL certificates, they're just used for their public and
  # private keys if AES security is enabled.)
  file { '/etc/puppetlabs/mcollective/ssl':
    ensure => directory,
    owner  => '0',
    group  => '0',
    mode   => '0755',
    notify => Service['mcollective'],
  }

  if $::operatingsystem == 'solaris' {
    exec { "Solaris: pe-mcollective log rotation":
      command   => "/usr/bin/echo '# pe-mcollective log rotation rule\n/var/log/pe-mcollective/mcollective.log -C 14 -c -p 1w' >> /etc/logadm.conf",
      unless    => "/usr/bin/grep 'pe-mcollective/mcollective.log' /etc/logadm.conf > /dev/null",
    }
  }

  # The use of the selector is because we can't use the file() function in a single
  # run on the puppet master.  The file won't exist until the catalog is applied.
  file { 'mcollective-public.pem':
    path    => '/etc/puppetlabs/mcollective/ssl/mcollective-public.pem',
    ensure  => file,
    source  => $pe_mcollective::is_puppetmaster ? {
      true  => '/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-mcollective-servers.pem',
      false => undef,
    },
    content => $pe_mcollective::is_puppetmaster ? {
      true  => undef,
      false => file('/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-mcollective-servers.pem'),
    },
    owner   => '0',
    group   => '0',
    mode    => '0644',
    notify  => Service['mcollective'],
  }
  # The use of the selector is because we can't use the file() function in a single
  # run on the puppet master.  The file won't exist until the catalog is applied.
  file { 'mcollective-private.pem':
    path    => '/etc/puppetlabs/mcollective/ssl/mcollective-private.pem',
    ensure  => file,
    source  => $pe_mcollective::is_puppetmaster ? {
      true  => '/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-mcollective-servers.pem',
      false => undef,
    },
    content => $pe_mcollective::is_puppetmaster ? {
      true  => undef,
      false => file('/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-mcollective-servers.pem'),
    },
    owner   => '0',
    group   => '0',
    mode    => '0600',
    notify  => Service['mcollective'],
  }
  # The use of the selector is because we can't use the file() function in a single
  # run on the puppet master.  The file won't exist until the catalog is applied.
  file { 'mcollective-cert.pem':
    path    => '/etc/puppetlabs/mcollective/ssl/mcollective-cert.pem',
    ensure  => file,
    source  => $pe_mcollective::is_puppetmaster ? {
      true  => '/etc/puppetlabs/puppet/ssl/certs/pe-internal-mcollective-servers.pem',
      false => undef,
    },
    content => $pe_mcollective::is_puppetmaster ? {
      true  => undef,
      false => file('/etc/puppetlabs/puppet/ssl/certs/pe-internal-mcollective-servers.pem'),
    },
    owner   => '0',
    group   => '0',
    mode    => '0644',
    notify  => Service['mcollective'],
  }
  file { '/etc/puppetlabs/mcollective/ssl/clients':
    ensure => directory,
    owner  => '0',
    group  => '0',
    mode   => '0755',
  }
  file { 'peadmin-public.pem':
    path    => '/etc/puppetlabs/mcollective/ssl/clients/peadmin-public.pem',
    source  => $pe_mcollective::is_puppetmaster ? {
      true  => '/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-peadmin-mcollective-client.pem',
      false => undef,
    },
    content => $pe_mcollective::is_puppetmaster ? {
      true  => undef,
      false => file('/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-peadmin-mcollective-client.pem'),
    },
    ensure  => 'file',
    owner   => '0',
    group   => '0',
    mode    => '0644',
    notify  => Service['mcollective'],
  }
  file { 'puppet-dashboard-public.pem':
    path    => '/etc/puppetlabs/mcollective/ssl/clients/puppet-dashboard-public.pem',
    source  => $pe_mcollective::is_puppetmaster ? {
      true  => '/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-puppet-console-mcollective-client.pem',
      false => undef,
    },
    content => $pe_mcollective::is_puppetmaster ? {
      true  => undef,
      false => file('/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-puppet-console-mcollective-client.pem'),
    },
    ensure  => 'file',
    owner   => '0',
    group   => '0',
    mode    => '0644',
    notify  => Service['mcollective'],
  }
  # All servers need the shared public key to decrypt and encrypt
  # registration messages.
  file { '/etc/puppetlabs/mcollective/ssl/clients/mcollective-public.pem':
    ensure  => absent,
  }

  # Manage the MCollective server configuration
  file { '/etc/puppetlabs/mcollective/server.cfg':
    ensure  => file,
    content => template("${module_name}/server.cfg.erb"),
    owner   => '0',
    group   => '0',
    mode    => '0600',
    notify  => Service['mcollective'],
  }
  service { 'mcollective':
    ensure     => running,
    name       => 'pe-mcollective',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

  # The Puppet Master is the only system to get the peadmin user account
  # and user-specific encryption keys.
  if $pe_mcollective::is_puppetmaster {
    pe_accounts::user { 'peadmin':
      ensure   => present,
      password => '!!',
      home     => '/var/lib/peadmin',
    }
    file { '/var/lib/peadmin/.mcollective':
      ensure  => file,
      content => template('pe_mcollective/client_peadmin.cfg.erb'),
      owner   => 'peadmin',
      group   => 'peadmin',
      mode    => '0600',
      require => Pe_accounts::User['peadmin'],
    }
    file { '/etc/puppetlabs/mcollective/client.cfg':
      ensure  => absent,
      owner   => '0',
      group   => '0',
      mode    => '0600',
    }
    file { '/var/lib/peadmin/.mcollective.d':
      ensure  => directory,
      owner   => 'peadmin',
      group   => 'peadmin',
      mode    => '0700',
      require => Pe_accounts::User['peadmin'],
    }
    file { '/var/lib/peadmin/.mcollective.d/peadmin-private.pem':
      ensure  => file,
      source  => '/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-peadmin-mcollective-client.pem',
      owner   => 'peadmin',
      group   => 'peadmin',
      mode    => '0600',
      require => [ Pe_accounts::User['peadmin'], Exec['mcollective-client-cert'] ],
    }
    file { '/var/lib/peadmin/.mcollective.d/peadmin-public.pem':
      ensure  => file,
      source  => '/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-peadmin-mcollective-client.pem',
      owner   => 'peadmin',
      group   => 'peadmin',
      mode    => '0644',
      require => [ Pe_accounts::User['peadmin'], Exec['mcollective-client-cert'] ],
    }
    file { '/var/lib/peadmin/.mcollective.d/peadmin-cert.pem':
      ensure  => file,
      source  => '/etc/puppetlabs/puppet/ssl/certs/pe-internal-peadmin-mcollective-client.pem',
      owner   => 'peadmin',
      group   => 'peadmin',
      mode    => '0644',
      require => [ Pe_accounts::User['peadmin'], Exec['mcollective-client-cert'] ],
    }
    # Because the accounts module is managing the .bashrc, we use
    # .bashrc.custom, which is included by default in the managed .bashrc
    file { '/var/lib/peadmin/.bashrc.custom':
      ensure  => file,
      content => template("${module_name}/bashrc_custom.erb"),
      owner   => 'peadmin',
      group   => 'peadmin',
      mode    => '0644',
      require => Pe_accounts::User['peadmin'],
    }
  }

  if $pe_mcollective::is_puppetconsole {
    # #9694 - Manage the encryption keys for the puppet-dashboard user as well.
    pe_accounts::user { 'puppet-dashboard':
      ensure   => present,
      password => '!!',
      home     => '/opt/puppet/share/puppet-dashboard',
    }
    # The home directory must be world-readable for the Dashboard to work
    # in Apache.  This resource is declared in the accounts::user defined
    # type.
    File <| title == '/opt/puppet/share/puppet-dashboard' |> {
      mode => '0755',
    }
    # Manage the path correctly
    file { '/opt/puppet/share/puppet-dashboard/.bashrc.custom':
      ensure  => file,
      content => template("${module_name}/bashrc_custom.erb"),
      owner   => 'puppet-dashboard',
      group   => 'puppet-dashboard',
      mode    => '0600',
      require => Pe_accounts::User['puppet-dashboard'],
    }
    file { '/opt/puppet/share/puppet-dashboard/.mcollective':
      ensure  => file,
      content => template('pe_mcollective/client_puppet_dashboard.cfg.erb'),
      owner   => 'puppet-dashboard',
      group   => 'puppet-dashboard',
      mode    => '0600',
      require => Pe_accounts::User['puppet-dashboard'],
    }
    file { '/opt/puppet/share/puppet-dashboard/.mcollective.d':
      ensure  => directory,
      owner   => 'puppet-dashboard',
      group   => 'puppet-dashboard',
      mode    => '0700',
      require => Pe_accounts::User['puppet-dashboard'],
    }
    # Master+console installs use source with a local file path for the content
    # console only installs use content with a file function to deliver in-band
    # Our basic premise is that master installs are completed before any console install.
    file { '/opt/puppet/share/puppet-dashboard/.mcollective.d/puppet-dashboard-private.pem':
      ensure  => file,
      content => $pe_mcollective::is_puppetmaster ? {
        true => undef,
        false => file('/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-puppet-console-mcollective-client.pem'),
      },
      source  => $pe_mcollective::is_puppetmaster? {
        true  => '/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-puppet-console-mcollective-client.pem',
        false => undef,
      },
      owner   => 'puppet-dashboard',
      group   => 'puppet-dashboard',
      mode    => '0600',
      require => $pe_mcollective::is_puppetmaster ? {
        true  => [ Pe_accounts::User['puppet-dashboard'], Exec['puppet-dashboard-client-cert'] ],
        false => Pe_accounts::User['puppet-dashboard'],
      },
    }
    file { '/opt/puppet/share/puppet-dashboard/.mcollective.d/puppet-dashboard-public.pem':
      ensure  => file,
      content => $pe_mcollective::is_puppetmaster ? {
        true  => undef,
        false => file('/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-puppet-console-mcollective-client.pem'),
      },
      source  => $pe_mcollective::is_puppetmaster ? {
        true  => '/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-puppet-console-mcollective-client.pem',
        false => undef,
      },
      owner   => 'puppet-dashboard',
      group   => 'puppet-dashboard',
      mode    => '0644',
      require => $pe_mcollective::is_puppetmaster ? {
        true  => [ Pe_accounts::User['puppet-dashboard'], Exec['puppet-dashboard-client-cert'] ],
        false => Pe_accounts::User['puppet-dashboard'],
      },
    }
    file { '/opt/puppet/share/puppet-dashboard/.mcollective.d/puppet-dashboard-cert.pem':
      ensure  => file,
      content => $pe_mcollective::is_puppetmaster ? {
        true  => undef,
        false => file('/etc/puppetlabs/puppet/ssl/certs/pe-internal-puppet-console-mcollective-client.pem'),
      },
      source  => $pe_mcollective::is_puppetmaster ? {
        true  => '/etc/puppetlabs/puppet/ssl/certs/pe-internal-puppet-console-mcollective-client.pem',
        false => undef,
      },
      owner   => 'puppet-dashboard',
      group   => 'puppet-dashboard',
      mode    => '0644',
      require => $pe_mcollective::is_puppetmaster ? {
        true  => [ Pe_accounts::User['puppet-dashboard'], Exec['puppet-dashboard-client-cert'] ],
        false => Pe_accounts::User['puppet-dashboard'],
      },
    }
  }
}
