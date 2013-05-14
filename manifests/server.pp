class openvpn::server($keyfile="/etc/openvpn/net/keys/dh1024.pem"){
  include openvpn::install, openvpn::service

  exec { "openvpn_dh":
    command => "/bin/mkdir -p $( /usr/bin/dirname ${keyfile} ) && /usr/bin/openssl dhparam -out ${keyfile} 1024",
    creates => $keyfile,
    require => File["/etc/openvpn"],
  }

  file { "/etc/openvpn":
    ensure  => directory,
    owner   => root,
    group   => root,
  }

  file { "/etc/openvpn/net.conf":
    ensure  => file,
    owner   => root,
    group   => root,
    mode    => 0644,
    content => template("openvpn/server-net.erb"),
    notify  => Class['openvpn::service'],
  }
}
