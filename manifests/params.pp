# == Class: nginx::params
#
# Parameters for: nginx.
#
# === Authors
#
# Nedap Steppingstone <steppingstone@nedap.com>
#
# === Copyright
#
# Copyright 2012 - 2013 Nedap Steppingstone.
#
class nginx::params {
  case $::osfamily {
    'Debian': {
      $package_nx    = 'nginx-extras'
      $user_nx       = 'www-data'
      $events_queue  = 'epoll'
      $dir_nx_conf   = '/etc/nginx'
      case $::lsbdistcodename {
        'squeeze': {
          $package_nx_ensure = '1.2.1-2.2~bpo60+2'
        }
        'wheezy': {
          $package_nx_ensure = '1.4.1'
        }
        # If we're not on stable or oldstable, assume we're not on
        # old-oldstable but either sid or experimental so set the
        # ensure to latest for the rolling release effect
        default: {
          $package_nx_ensure = 'latest'
        }
      }
    }
    default: {
      fail("\$osfamily ${::osfamily} is not supported by the nginx module.")
    }
  }
}
