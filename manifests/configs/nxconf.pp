# == Class: nginx::configs::nxconf
#
# Configuration for: nginx.
#
# === Parameters
#
# [*dir_www*]
#   _default_: +dir_www+ from nginx.
# [*dir_nx_conf*]
#   _default_: +dir_nx_conf+ from nginx.
# [*user_nx*]
#   _default_: +user_nx+ from nginx.
# [*default_status*]
#   _default_: +default_status+ from nginx.
# [*ipv6+]
#   _default_: +ipv6+ from nginx.
# [*workers*]
#   _default_: +workers+ from nginx.
# [*worker_connections*]
#   _default_: +woker_connections+ from nginx.
# [*events_queue*]
#   _default_: +events_queue+ from nginx.
# [*status_allowed_ips*]
#   _default_: +status_allowed_ips+ from nginx.
# [*default_mime_type*]
#   _default_: +default_mime_type+ from nginx.
# [*server_names_hash_bucket_size*]
#   _default_: +server_names_hash_bucket_size+ from nginx.
# [*types_hash_max_size*]
#   _default_: +types_hash_max_size+ from nginx.
# [*server_tokens*]
#   _default_: +server_tokens+ from nginx.
# [*ssl_features*]
#   _default_: +ssl_features+ from nginx.
# [*keepalive_timeout*]
#   _default_: +keepalive_timeouts+ from nginx.
# [*sendfile*]
#   _default_: +sendfile+ from nginx.
# [*sendfile_max_chunk*]
#   _default_: +sendfile_max_chunk+ from nginx.
# [*tcp_nodelay*]
#   _default_: +tcp_nodelay+ from nginx.
# [*tcp_nopush*]
#   _default_: +tcp_nopush+ from nginx.
# [*gzip*]
#   _default_: +gzip+ from nginx.
# [*gzip_config*]
#   _default_: +gzip_config+ from nginx.
# [*naxsi*]
#   _default_: +naxsi+ from nginx.
#
# === Variables
#
# [*nx_conf*]
#   _default_: <tt>dir_nx_conf/nginx.conf</tt>
#
#   The main nginx configuration file.
#
# === Concat fragments
# A listing of the different fragments, what they do and how they are
# ordered.
#
# ==== nx_events
# Any fragment with an +order+ between <tt>011</tt> and <tt>019</tt> will be
# rendered at the end of the +events+ configuration block.
#
# [*nx_root*]
#   _order_: 001
#
#   This fragment is rendered at the top of +nx_conf+
#   and contains settings that are set outside the +http+
#   context.
#
# [*nx_events_start*]
#   _order_: 010
#
#   This fragment renders the opening line of the +events+
#   section.
#
# [*nx_events_body*]
#   _order_: 011
#
#   This fragment renders the body of the +events+ section,
#   immediately after the start of the section.
#
# [*nx_events_end*]
#   _order_: 019
#
#   Renders the closing of the +events+ section.
#
# ==== nx_http
# Any fragment with an +order+ between <tt>021</tt> and <tt>029</tt> will be
# rendered at the end of the +http+ configuration block.
#
# [*nx_http_start*]
#   _order_: 020
#
#   This fragment renders the opening line of the +http+
#   section.
#
# [*nx_http_body*]
#   _order_: 021
#
#   This fragment renders the body of the +http+ section,
#   immediately after the start of the section.
#
# [*nx_http_end*]
#   _order_: 029
#
#   Renders the closing of the +http+ section including the last two
#   configuration directives which load configuration files from
#   <tt>dir_nx_conf/conf.d/</tt> and vhosts available in
#   <tt>dir_nx_conf/sites-enabled/</tt>.
#
# === Authors
#
# Nedap Steppingstone <steppingstone@nedap.com>
#
# === Copyright
#
# Copyright 2012 - 2013 Nedap Steppingstone.
#
class nginx::configs::nxconf(
  $dir_www                       = $::nginx::dir_www,
  $dir_nx_conf                   = $::nginx::dir_nx_conf,
  $user_nx                       = $::nginx::user_nx,
  $default_status                = $::nginx::default_status,
  $ipv6                          = $::nginx::ipv6,
  $workers                       = $::nginx::workers,
  $worker_connections            = $::nginx::worker_connections,
  $events_queue                  = $::nginx::events_queue,
  $status_allowed_ips            = $::nginx::status_allowed_ips,
  $default_mime_type             = $::nginx::default_mime_type,
  $server_names_hash_bucket_size = $::nginx::server_names_hash_bucket_size,
  $types_hash_max_size           = $::nginx::types_hash_max_size,
  $server_tokens                 = $::nginx::server_tokens,
  $ssl_features                  = $::nginx::ssl_features,
  $keepalive_timeout             = $::nginx::keepalive_timeout,
  $sendfile                      = $::nginx::sendfile,
  $sendfile_max_chunk            = $::nginx::sendfile_max_chunk,
  $tcp_nodelay                   = $::nginx::tcp_nodelay,
  $tcp_nopush                    = $::nginx::tcp_nopush,
  $gzip                          = $::nginx::gzip,
  $gzip_config                   = $::nginx::gzip_config,
  $naxsi                         = $::nginx::naxsi,
){

  concat_build { 'nxconf':
    order => ['*.conf'],
  }

  concat_fragment { 'nxconf+001-start.conf':
    content => template('nginx/config/_root.nginx.conf.erb'),
  }

  concat_fragment { 'nxconf+010-events-start.conf':
    content => 'events {',
  }

  concat_fragment { 'nxconf+011-events_body.conf':
    content => template('nginx/config/_events.nginx.conf.erb'),
  }

  concat_fragment { 'nxconf+019-events-end.conf':
    content => '}',
  }

  concat_fragment { 'nxconf+020-http-start.conf':
    content => 'http {',
  }

  concat_fragment { 'nxconf+021-http-body.conf':
    content => template('nginx/config/_http.nginx.conf.erb'),
  }

  concat_fragment { 'nxconf+029-http-body-end.conf':
    content => "  include conf.d/*.conf;\n  include sites-enabled/*;\n}",
  }

  file { "${dir_nx_conf}/nginx.conf":
    owner   => root,
    group   => root,
    mode    => '0640',
    require => Concat_build['nxconf'],
    source  => concat_output('nxconf'),
  }

  file { "${dir_nx_conf}/conf.d/ssl.conf":
    owner   => root,
    group   => root,
    mode    => '0640',
    content => template('nginx/config/ssl.conf.erb'),
  }

}
