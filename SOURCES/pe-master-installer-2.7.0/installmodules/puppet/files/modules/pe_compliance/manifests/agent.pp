class pe_compliance::agent {
  cron { 'report_baseline':
    command     => 'PATH=/opt/puppet/bin:/bin:/usr/bin:/usr/sbin:/usr/local/bin /opt/puppet/bin/puppet inspect 1> /dev/null',
    hour        => '20',
    minute      => '0',
  }
}
