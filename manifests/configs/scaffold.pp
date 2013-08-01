# == Class: nginx::configs::scaffold
class nginx::configs::scaffold(
  $dir_nx_conf = $::nginx::dir_nx_conf,
  $dir_www     = $::nginx::dir_www,
){

  file { $::nginx::dir_www:
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0644',
  }

  file { "${dir_www}/error_pages":
    ensure  => directory,
    source  => 'puppet:///modules/nginx/error_pages',
    recurse => true,
    purge   => true,
    owner   => root,
    group   => root,
    mode    => '0644',
  }

  file { "${dir_nx_conf}/ssl":
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0640',
  }

  file { "${dir_nx_conf}/conf.d":
    ensure  => directory,
    source  => 'puppet:///modules/nginx/conf.d',
    recurse => true,
    purge   => true,
    owner   => root,
    group   => root,
    mode    => '0640',
  }

}
