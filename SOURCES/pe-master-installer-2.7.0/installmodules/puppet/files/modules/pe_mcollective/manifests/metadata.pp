# Class[pe_mcollective::metadata]
#
# Simple class to manage facter metadata updates for MCollective in PE.  This
# really amounts to a simple cron resource.
#
class pe_mcollective::metadata {
  file { '/opt/puppet/sbin/refresh-mcollective-metadata':
    owner   => '0',
    group   => '0',
    mode    => '0755',
    content => template('pe_mcollective/refresh-mcollective-metadata'),
    before  => Cron['pe-mcollective-metadata'],
  }
  cron { 'pe-mcollective-metadata':
    command => '/opt/puppet/sbin/refresh-mcollective-metadata',
    user    => 'root',
    minute  => [ '0',
                 '15',
                 '30',
                 '45' ],
  }
}
