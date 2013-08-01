# == Class nginx::configs
#
# Executes the different parts of configuring nginx
# in the right order.
#
# === Authors
#
# Nedap Steppingstone <steppingstone@nedap.com>
#
# === Copyright
#
# Copyright 2012 - 2013 Nedap Steppingstone.
class nginx::configs {
  class { '::nginx::configs::clean': }    ->
  class { '::nginx::configs::scaffold': } ->
  class { '::nginx::configs::nxconf': }   ->
  Class['::nginx::configs']
}
