OpenVPN Server / Client
=======================

This installs and configures OpenVPN. The OpenVPN clients reuse the Puppet certificates of the client to connect to the server.

Usage
=====

    # Within site.pp
    node /server/ {
      include openvpn::server
    }

    node /client/ {
      class { "openvpn::client":
        server    => "server",
        client_ip => "10.100.1.10",
      }
    }

This module is used in production on Ubuntu 12.04.
