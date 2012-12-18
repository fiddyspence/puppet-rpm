define install::symlink () {
  file { "/usr/local/bin/${name}":
    ensure => link,
    target => "/opt/puppet/bin/${name}",
  }
}


