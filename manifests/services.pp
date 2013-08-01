# == Class: nginx::services
#
# Services for: nginx.
#
# === Authors
#
# Nedap Steppingstone <steppingstone@nedap.com>
#
# === Copyright
#
# Copyright 2012 - 2013 Nedap Steppingstone.
#
class nginx::services(
  $ensure = 'running',
  $enable = true,
){

  validate_re($ensure, '^running|stopped|true|false')
  validate_bool($enable)

  service { 'nginx':
    ensure     => $ensure,
    enable     => $enable,
    hasrestart => true,
    hasstatus  => true,
    restart    => 'service nginx reload',
  }

}
