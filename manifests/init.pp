class openvpn_server {
		package { "openvpn":
		ensure	=> "installed"
	}
	
	service { "openvpn":
		ensure	=> "running",
		require	=> Package["openvpn"],
	}
	
	file { "/etc/openvpn":
		ensure	=> "directory",
		recurse	=> true,
		purge	=> true,
		force	=> true,
		notify	=> Service["openvpn"],
		owner	=> "root",
		group	=> "root",
		source	=> "puppet:///modules/openvpn_server/configs/",
	}
}