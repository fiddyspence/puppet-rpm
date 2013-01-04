class puppet::params {

#  For initial setup, we need this shit here:
$installerexists = inline_template('<%= File.exists?("/etc/puppetlabs/installer/data") %>')
if $installerexists == 'false' { 
  
    $dnsaltnames = inline_template('<%= @fqdn -%>,<%= hostname -%>,puppet,puppet.<%= @domain -%>')
    $dbpassword = inline_template('<%= Digest::SHA1.hexdigest("#{10.times.map { rand(rand(1000000000)) }.join }")[0,20] -%>')
    $rootmysqlpassword = inline_template('<%= Digest::SHA1.hexdigest("#{10.times.map { rand(rand(1000000000)) }.join }")[0,20] -%>')
    $consoledbname = 'console'
    $consoleuser = 'console'
    $consolepassword = inline_template('<%= Digest::SHA1.hexdigest("#{10.times.map { rand(rand(1000000000)) }.join }")[0,20] -%>')
  
    file { '/etc/puppetlabs/installer':
      ensure => directory,
    }
    file { '/etc/puppetlabs/installer/data':
      ensure   => file,
      content  => inline_template("<%= scope.to_hash(recursive = false).reject { |k,v| !( k.is_a?(String) && v.is_a?(String) ) }.to_yaml %>"),
      mode     => '0600',
      owner    => 'root',
      group    => 'root',
      replace  => 'false',
    }
    $installerdata = {
      dnsaltnames       => $dnsaltnames,
      dbpassword        => $dbpassword,
      rootmysqlpassword => $rootmysqlpassword,
      consoledbname     => $consoledbname,
      consoleuser       => $consoleuser,
      consolepassword   => $consolepassword,
    }

  } else {

    $installerdata = loadyaml('/etc/puppetlabs/installer/data')

  }


  $modules = ['accounts','auth_conf','baselines','concat','mcollectivepe','pe_accounts','pe_compliance','pe_mcollective','request_manager','stdlib']



}
