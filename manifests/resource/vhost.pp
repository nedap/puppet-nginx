# == Define: nginx::resource::vhost
# === Variables
#
# [*resource_name*]
#   _default_: +$name+
#
#   Contains the name of the vhost resource we're trying to create.
#   This is just for convenience so we van use +$resource_name+ instead
#   of +$name+ as +$name+ changes per resource scope.
#
# [*file_vhost*]
#   The full path of the file resource containing the vhost we're
#   trying to create.
#
# [*link_vhost*]
#   The full path of the symlink we want to create in order for nginx
#   to pick up on our vhost.
#
# [*file_ensure*]
#   _default_: +file+
#
#   This variable is set according to the +$ensure+ parameter of this
#   resource:
#   * +true+: +file+
#   * +false+: +absent+
#
# [*link_ensure*]
#   _default_: +link+
#
#   This variable is set according to the +$ensure+ parameter of this
#   resource:
#   * +true+: +link+
#   * +false+: +absent+
#
# === Authors
#
# Nedap Steppingstone <steppingstone@nedap.com>
#
# === Copyright
#
# Copyright 2012 - 2013 Nedap Steppingstone.
#
define nginx::resource::vhost(
  $server_name,
  $enable                    = true,
  $purge                     = false,
  $upstream                  = false,
  $docroot                   = "/var/www/${server_name}",
  $access_log                = "/var/log/nginx/${server_name}_access.log",
  $error_log                 = "/var/log/nginx/${server_name}_error.log",
  $http_port                 = 80,
  $https_port                = 443,
  $ipv6                      = true,
  $ssl                       = false,
  $ssl_cert                  = undef,
  $ssl_key                   = undef,
  $redirect_to_https         = true,
  $strict_transport_security = true,
  $strict_transport_max_age  = 31536000,
  $error_pages               = {},
){
  validate_bool($enable)
  validate_bool($purge)
  validate_absolute_path($docroot)
  validate_absolute_path($access_log)
  validate_absolute_path($error_log)
  validate_string($http_port)
  validate_string($https_port)
  validate_bool($ssl)
  validate_bool($redirect_to_https)
  validate_bool($strict_transport_security)
  validate_string($strict_transport_max_age)
  validate_hash($error_pages)

  if ! is_integer($http_port) {
    fail('$http_port must be an integer.')
  }

  if ! is_integer($https_port) {
    fail('$https_port must be an integer.')
  }

  if $ssl and !$ssl_key {
    fail('Need $ssl_key if $ssl is true.')
  } else {
    validate_string($ssl_key)
  }

  if $ssl and !$ssl_cert {
    fail('Need $ssl_cert if $ssl is true.')
  } else {
    validate_string($ssl_cert)
  }

  if ! is_integer($strict_transport_max_age) {
    fail('$strict_transport_max_age must be an integer.')
  }

  if (!is_string($server_name) and !is_array($server_name)) {
    fail('$server_name must either be a string or an array.')
  }

  if ($enable and $purge) {
    fail('Cannot purge the configuration file but leave the symlink.')
  }

  $resource_name = $name

  # if purge=false, so we actually want to write/build the configuration
  # file.
  if ! $purge {
    concat_build { $resource_name:
      order => ['*.conf'],
    }

    # if upstream=true, create the start and end upstream block
    if $upstream {
      concat_fragment { "${resource_name}+000-upstream_start.conf":
        content => 'upstream {',
      }

      concat_fragment { "${resource_name}+099-upstream_end.conf":
        content => '}',
      }
    }

    # create a server http block
    concat_fragment { "${resource_name}+100-http_start.conf":
      content => 'server {',
    }

    concat_fragment { "${resource_name}+110-http_body.conf":
      content => template('nginx/vhost/_http.erb'),
    }

    concat_fragment { "${resource_name}+199-http_end.conf":
      content => '}',
    }

    # if ssl=true, create a server https block that is mostly
    # identical to the server http block we created earlier
    if $ssl {
      concat_fragment { "${resource_name}+200-https_start.conf":
        content => 'server {',
      }

      concat_fragment { "${resource_name}+210-https_body.conf":
        content => template('nginx/vhost/_https.erb'),
      }

      concat_fragment { "${resource_name}+299-https_end.conf":
        content => '}',
      }
    }
  }

  if $enable {
    if $purge {
      $link_ensure = 'absent'
    } else {
      $link_ensure = 'link'
    }
  } else {
    $link_ensure = 'absent'
  }

  if $purge {
    $file_ensure = 'absent'
    $file_require = Class['::nginx::configs']
  } else {
    $file_ensure = 'file'
    $file_require = [
      Class['::nginx::configs'],
      Concat_build[$resource_name],
    ]
  }

  $file_vhost = "${::nginx::dir_nx_conf}/sites-available/${resource_name}.conf"
  $link_vhost = "${::nginx::dir_nx_conf}/sites-enabled/${resource_name}.conf"

  # Create the actual file resource with source the
  # concat_build we defined earlier
  file { $file_vhost:
    ensure  => $file_ensure,
    owner   => root,
    group   => root,
    mode    => '0644',
    source  => concat_output($resource_name),
    require => $file_require,
    notify  => Class['::nginx::services'],
  }

  file { $link_vhost:
    ensure  => $link_ensure,
    target  => $file_vhost,
    notify  => Class['::nginx::services'],
  }
}
