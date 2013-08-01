# == Class: nginx
#
# Manages nginx.
#
# === Parameters
#
# [*dir_www*]
#   _default_: <tt>/var/www</tt>
#
#   The directory to use as the root path for vhosts. We'll
#   also create a directory here to hold our custom error pages.
#
# [*dir_nx_conf*]
#   _default_: +dir_nx_conf+ from nginx::params class.
#
#   The dircetory holding the nginx configurtion.
#
# [*package_nx*]
#   _default_: +package_nx+ from nginx::params class.
#
#   The name of the package we want to install that holds the nginx daemon
#   and the set of modules we require. This will usually be one of:
#   * <em>nginx</em>
#   * <em>nginx-light</em>
#   * <em>nginx-full</em>
#   * <em>nginx-extras</em>
#   * <em>nginx-naxsi</em>
#   * <em>nginx-naxsi-ui</em>
#
#   *Note*: this package is likely to depend on the OpenSSL library but isn't
#   being managed by this module. It will usually be pulled in by your package
#   manager.
#
# [*package_nx_ensure*]
#   _default_: +package_nx_ensure+ from nginx::params class.
#
#   The version of the nginx package we want installed. This is validated
#   through a reqular expression that requires at least version <b>1.2</b> or
#   any other valid ensure state.
#
#   *Note*: if you set this to +latest+ and +latest+ happens to be older than
#   <b>1.2</b> the validator will pass but this module may malfunction.
#
# [*user_nx*]
#   _default_: +user_nx+ from nginx::params class.
#
#   The user the nginx daemon should run as.
#
# [*default_status*]
#   _default_: +true+
#
#   Create a +default_server+ catching all requests with the status stub
#   enabled on it.
#
# [*status_allowed_ips*]
#   _default_: The IP-ranges defined in IANA's non-routeable address space
#   except for the documentation range.
#
#   The range of IP addresses allowed to access the information outputted
#   by the stub status module.
#
# [*worker*]
#   _default_: +$::processorcount+ (Facter)
#
#   The amount of workers nginx should start with. A rule of thumb is the
#   same as there are CPU's/cores on the machine.
#
# [*worker_connections*]
#   _default_: 2048
#
#   The amount of connections a worker will accept. This also impacts the
#   amount of file descriptors nginx uses.
#
# [*events_queue*]
#   _default_: +events_queue+ from nginx::params class.
#
#   The queue model nginx will use. The available queue's are configured at
#   compile time. Linux usually supports +select+, +poll+ and +epoll+, *BSD's
#   do +select+, +poll+ or +kqueue+, +rtsig+ for realtime Linux kernels and
#   <tt>/dev/poll</tt> or +eventport+ for Solaris.
#
# [*default_mime_type*]
#   _default_: <tt>application/octetstream</tt>
#
#   The MIME type to be used for files we do not have a MIME type definition
#   for.
#
# [*server_names_hash_bucket_size*]
#   _default_: 32
#
#   This sets the size of the bucket that nginx uses that contains all the
#   server names. Effectively, if you set this to 1 you'll only be able to bring
#   nginx online if you have only one vhost / server_name directive.
#
#   This value is usually set in a power of two, so: 32, 64, 128 and so forth.
#
# [*types_hash_max_size*]
#   _default_: 2048
#
#   The size of the hash containing the (MIME) types. Needs to be big enough to
#   contain them or nginx will complain at reload.
#
# [*server_tokens*]
#   _default_: +false+
#
#   Turns the display on or off for server tokens:
#   * +false+: off
#   * +true+: on
#
# [*ssl_features*]
#   _default_:
#   {
#     'protocols'      => ['SSLv3', 'TLSv1', 'TLSv1.1', 'TLSv1.2'],
#     'sessions_cache' => false,
#     'ciphers'        => ['HIGH','!aNULL','!MD5','!SSLv2',
#                          '!ADH','!eNULL','!NULL','!RC4']
#   }
#
#   This configures some SSL settings for the server. It allows to set:
#   * session cache
#   * ciphers
#   * protocols
#
#   *Note*: The default configuration makes you vulnerable for the BEAST
#   attack. This is a direct consequence of the fact that we disable the
#   broken RC4 cipher. To avoid this you can either enable RC4 to mitigate
#   the BEAST attack (but allow for the use of a broken cipher) or remove
#   TLSv1 from the protocols array.
#
# [*keepalive_timeout*]
#   _default_: 25
#
#   The timeout, in seconds, after which we close a connection.
#
# [*sendfile*]
#   _default_: +true+
#
#   Enables the use of the <tt>sendfile()</tt> directive.
#
# [*sendfile_max_chunk*]
#   _default_: 0
#
#   Limit the amount of data that can be transfered in a single
#   <tt>sendfile()</tt> call.
#
# [*tcp_nopush*]
#   _default_: +true+
#
#   Allows the use of +TCP_NOPUSH+ (BSD) or +TCP_CORK+ (Linux) option
#   on a socket when using <tt>sendfile()</tt>.
#
# [*tcp_nodelay*]
#   _default_: +true+
#
#   Allow the use of +TCP_NODELAY+ option on a socket for +keep-alive+
#   connections.
#
# [*gzip*]
#   _default_: +true+
#
#   Turns on gzip.
#
# [*gzip_config*]
#   _default_:
#   * +disable+: msie6, disables gzip for Internet Explorer 6
#   * +vary+: on
#   * +comp_level+: 6
#   * +buffers+: 16 8k
#   * +http_version+: 1.1
#   * +types+: text/plain', 'text/css', 'text/xml', 'text/javascript',
#    'application/json', 'application/x-javascript', 'application/xml',
#    'application/xml-rss', 'font/ttf', 'font/otf', 'image/svg+xml'
#
#   Is a hash of configuration options for gzip. The hash key will be joined
#   with the +gzip_+ string to result in the configuration directive name.
#
#   The +types+ key expects an array of MIME types as strings for which we
#   wish to turn on gzip compression.
#
# === Variables
#
# [*naxsi*]
#   If +package_nx+ contains the string _naxsi_ we turn on support for
#   {naxsi}[https://code.google.com/p/naxsi/]. This means the global
#   configuration will get <tt>naxi_core.rules</tt> loaded.
#
# === Authors
#
# Nedap Steppingstone <steppingstone@nedap.com>
#
# === Copyright
#
# Copyright 2012 - 2013 Nedap Steppingstone.
#
class nginx(
  $dir_www                       = '/var/www',
  $dir_nx_conf                   = $::nginx::params::dir_nx_conf,
  $package_nx                    = $::nginx::params::package_nx,
  $package_nx_ensure             = $::nginx::params::package_nx_ensure,
  $user_nx                       = $::nginx::params::user_nx,
  $default_status                = true,
  $ipv6                          = true,
  $status_allowed_ips            = ['127.0.0.1', '10.0.0.0/8',
                                    '192.168.0.0/16', '172.16.0.0/12'],
  $workers                       = $::processorcount,
  $worker_connections            = 2048,
  $events_queue                  = $::nginx::params::events_queue,
  $default_mime_type             = 'application/octet-stream',
  $server_names_hash_bucket_size = 32,
  $types_hash_max_size           = 2048,
  $server_tokens                 = false,
  $ssl_features                  = {
    'protocols'      => ['SSLv3', 'TLSv1', 'TLSv1.1', 'TLSv1.2'],
    'sessions_cache' => false,
    'ciphers'        => ['HIGH','!aNULL','!MD5','!SSLv2',
                        '!ADH','!eNULL','!NULL','!RC4']
  },
  $keepalive_timeout             = 25,
  $sendfile                      = true,
  $sendfile_max_chunk            = 0,
  $tcp_nodelay                   = true,
  $tcp_nopush                    = true,
  $gzip                          = true,
  $gzip_config                   = {
    'disable'      => 'msie6',
    'vary'         => 'on',
    'comp_level'   => '6',
    'buffers'      => '16 8k',
    'http_version' => '1.1',
    'types'        => [ 'text/css',
                        'text/javascript',
                        'text/plain',
                        'text/xml',
                        'application/json',
                        'application/x-javascript',
                        'application/xml',
                        'application/xml-rss',
                        'font/ttf',
                        'font/otf',
                        'image/svg+xml',
                      ],
  }
) inherits nginx::params {

  # Check if users aren't being nice
  validate_absolute_path($dir_www)
  validate_absolute_path($dir_nx_conf)
  validate_string($package_nx)
  validate_re($package_nx_ensure,
    '^(1\.([2-9]|\d+)\.\d+)|absent|latest|purged|held|present|installed',
    'The nginx version must be at least 1.2 or a supported ensure state
  for the package resource such as latest.')
  validate_string($user_nx)
  validate_bool($default_status)
  validate_re($events_queue,
    '^select|poll|epoll|kqueue|rtsig|/dev/poll|eventport',
    'See http://wiki.nginx.org/EventsModule#use for valid parameters.')
  validate_array($status_allowed_ips)
  validate_string($default_mime_type)
  validate_bool($server_tokens)
  validate_hash($ssl_features)
  validate_array($ssl_features['protocols'])
  validate_array($ssl_features['ciphers'])
  validate_string($keepalive_timeout)
  validate_bool($sendfile)
  validate_bool($tcp_nodelay)
  validate_bool($tcp_nopush)
  validate_bool($gzip)
  validate_hash($gzip_config)
  validate_array($gzip_config['types'])

  if $package_nx =~ /passenger/ {
    fail('This module does not support configuring nginx with built-in
    Passenger support. Feel free to add it or proxy to a Passenger-standalone
    instance.')
  }

  if $package_nx =~ /naxsi/ {
    $naxsi = true
  } else {
    $naxsi = false
  }

  # Bunch of is_integer checks just to make sure people aren't
  # misbehaving.
  if !is_integer($workers) {
    fail('$workers must be an integer, greater or equal to 1')
  }

  if !is_integer($worker_connections) or $worker_connections < 1 {
    fail('$worker_connections must be an integer, greater or equal to 1.')
  }

  if !is_integer($server_names_hash_bucket_size) or
  $server_names_hash_bucket_size < 1 {
    fail('$server_names_hash_bucket_size must be an integer,
    greater or equal to 1.')
  }

  if !is_integer($types_hash_max_size) or
  $types_hash_max_size < 1 {
    fail('$types_hash_max_size must be an integer,
    greater or equal to 1.')
  }

  if !is_integer($keepalive_timeout) or
  $keepalive_timeout < 0 {
    fail('$keepalive_timeout must be an integer,
    greater or equal to 0.')
  }

  if !is_integer($sendfile_max_chunk) or
  $sendfile_max_chunk < 0 {
    fail('$sendfile_max_chunk must be an integer,
    greater or equal to 0.')
  }

  # Execute our configuration classes
  class { '::nginx::packages': } ->
  class { '::nginx::configs': }  ->
  class { '::nginx::services': } ->
  Class['::nginx']

}
