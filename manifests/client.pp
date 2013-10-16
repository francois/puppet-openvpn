class openvpn::client($server, $client_ip=undef, $compress=true, $cert="/var/lib/puppet/ssl/certs/${hostname}.pem", $key="/var/lib/ssl/private_keys/${hostname}.pem"){
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

  if $client_ip {
    @@openvpn::client_config{$hostname:
      ensure    => present,
      client_ip => $client_ip,
    }
  } else {
    @@openvpn::client_config{$hostname:
      ensure    => absent,
      client_ip => '0.0.0.0',
    }
  }
}
