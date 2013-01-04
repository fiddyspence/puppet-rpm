class puppet::mysql {

  class { 'mysql::server':
    config_hash => { 'root_password' => $puppet::params::installerdata['rootmysqlpassword'] }
  }

  database { 'console':
    charset => 'utf8',
  }
  database { 'console_auth':
    charset => 'utf8',
  }
  database { 'console_inventory_service':
    charset => 'utf8',
  }

  database_user { "${puppet::params::consoleuser}@localhost":
    password_hash => mysql_password($puppet::params::installerdata['consolepassword']),
  }

  database_grant { "${puppet::params::installerdata['consoleuser']}@localhost/console":
    privileges => ['all'],
  }
  database_grant { "${puppet::params::installerdata['consoleuser']}@localhost/console_auth":
    privileges => ['all'],
  }
  database_grant { "${puppet::params::installerdata['consoleuser']}@localhost/console_inventory_service":
    privileges => ['all'],
  }

}
