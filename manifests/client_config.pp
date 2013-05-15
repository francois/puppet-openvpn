define openvpn::client_config($ensure, $client_ip){
  file{"/etc/openvpn/net/client-configs/${name}":
    ensure  => $ensure,
    content => template('openvpn/client-configs.erb'),
  }
}
