class openvpn::install{
  package { "openvpn":
    ensure => installed
  }

  service { "openvpn":
    ensure  => running,
    require => Package[openvpn],
  }
}
