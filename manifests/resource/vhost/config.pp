# == Define: nginx::resource::vhost::config
define nginx::resource::vhost::config(
  $target,
  $order,
  $content,
){

  validate_string($target)
  validate_string($order)
  validate_string($content)

  $resource_name = $name

  concat_fragment{ "${target}+${order}-${resource_name}.conf":
    content => $content,
  }
}
