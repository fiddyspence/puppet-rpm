define masterinstall::symlink () {
  file { "/usr/local/bin/${name}":
    ensure => link,
    target => "/opt/puppet/bin/${name}",
  }
}


