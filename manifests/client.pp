class openvpn::client ($server, $client_ip) {
  include openvpn::install, openvpn::service

  file { "/etc/openvpn":
    ensure  => directory,
    owner   => root,
    group   => root,
  }

  file { "/etc/openvpn/net.conf":
    owner   => root,
    group   => root,
    mode    => 0644,
    content => template("openvpn/client-net.erb"),
    notify  => Class['openvpn::service'],
  }
}
