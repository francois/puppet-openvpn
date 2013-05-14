class openvpn::service{
  service { "openvpn":
    ensure  => running,
    require => Class['openvpn::install'],
  }
}
