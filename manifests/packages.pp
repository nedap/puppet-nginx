# == Class: nginx::packages
#
# Packages for: nginx.
#
# === Authors
#
# Nedap Steppingstone <steppingstone@nedap.com>
#
# === Copyright
#
# Copyright 2012 - 2013 Nedap Steppingstone.
#
class nginx::packages(
  $package_nx = $::nginx::package_nx,
  $package_nx_ensure = $::nginx::package_nx_ensure,
){

  package { $package_nx:
    ensure => $package_nx_ensure,
    name   => 'nginx',
    notify => [
      Class['nginx::configs'],
      Class['nginx::services'],
    ],
  }
}
