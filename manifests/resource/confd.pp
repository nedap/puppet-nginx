# == Define: nginx::resource::confd
#
# This is a defined type that allows you to create a
# file in conf.d/name.conf with arbitrary content.
#
# This file will be automatically loaded by nginx on
# start/restart/reload so make sure it's actually valid.
#
# === Parameters
#
# [*enable*]
#   _default_: +true+
#
# If this file should exist or not. Set it to true to create
# the file, false and it will be removed.
#
# [*content*]
#   _default_: ''
#
# This maps directly to the content parameter of the file resource
# that is created through this type.
# [*source*]
#   _default_: ''
#
# This maps directly to the source parameter of the file resource
# that is created through this type.
#
# [*dir_nx_conf*]
#   _default_: +dir_nx_conf+ from nginx.
#
# === Variables
#
# [*resource_name*]
#   _default_: +$name+
#
# Contains the name of the confd resource we're trying to create.
# This is just for convenience so we van use +$resource_name+ instead
# of +$name+ as +$name+ changes per resource scope.
#
# === Authors
#
# Nedap Steppingstone <steppingstone@nedap.com>
#
# === Copyright
#
# Copyright 2012 - 2013 Nedap Steppingstone.
#
define nginx::resource::confd(
  $enable      = true,
  $content     = undef,
  $source      = undef,
  $dir_nx_conf = $::nginx::dir_nx_conf,
){

  validate_string($content)
  validate_string($source)
  validate_bool($enable)

  if ($enable and empty($content) and empty($source)) {
    fail('Need either a content or a source.')
  }

  if $enable {
    $file_ensure = 'file'
  } else {
    $file_ensure = 'absent'
  }

  $resource_name = $name

  file { "${dir_nx_conf}/conf.d/${resource_name}.conf":
    ensure  => $file_ensure,
    owner   => root,
    group   => root,
    mode    => '0640',
    content => $content,
    source  => $source,
    require => Class['::nginx::configs'],
    notify  => Class['::nginx::services'],
  }
}
