# == Class: nginx::configs::clean
class nginx::configs::clean(
  $dir_nx_conf = $::nginx::dir_nx_conf,
){

  file { $dir_nx_conf:
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0644',
    recurse => true,
    force   => true,
    purge   => true,
  }

  file { "${dir_nx_conf}/sites-available":
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0644',
    recurse => true,
    force   => true,
    purge   => true,
  }

  file { "${dir_nx_conf}/sites-enabled":
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0644',
    recurse => true,
    force   => true,
    purge   => true,
  }
}
