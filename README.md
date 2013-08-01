# nginx

This is the nginx module.

## Basic usage

This module manages nginx.

It should be included on any host that needs nginx.

```puppet
class { 'nginx': }
```

## Configuring a vhost

To build the basic skeleton of a vhost the ``nginx::vhost`` type can be used.
It will generate a nginx configuration file and symlink it after which nginx
is reloaded.

To expand on that configuration and include arbitrary configuration this module
does not provide for the ``nginx::vhost::config`` type is provided. The target
parameter of that module must be the name of the ``nginx::vhost`` resource you
created before.

```puppet
nginx::vhost { 'site1':
  server_name => 'site.example.com',
}

nginx::vhost::config { 'site1-http-extra-option':
  target  => 'site1',
  order   => '120',
  content => 'Arbitrary configuration you want to add to the generated file',
}
```

## Order
This module and it's types make heavy use of the native concat type from
the Onyxpoint concat module.

In order to be able to inject configuration in either the generated ``nginx.conf``
or one of the vhosts order ranges have been set up.

### Order nginx.conf

  * 001: the first line this module generates. If you need something before
         that, an order of 000.
  * 010: opens the 'events' configuration block
  * 011: writes the default events configuration block provided by this module
  * 012-018: free for your use
  * 019: closes the 'events' configuration block
  * 020: opens the 'http' configuration block
  * 021: writes the default http configuration provided by this module
  * 022-028: free for your use
  * 029: closes the 'http' configuration block
  * 030-099: free for your use

### Order vhost

  * 000: opens the 'upstream' block
  * 001-098: free for your use
  * 099: closes the 'upstream' block
  * 100: opens the 'http' block
  * 101-198: free for your use
  * 199: closes the' http' block
  * 200: opens the 'https' block
  * 201-298: free for your use
  * 299: closes the 'https' block

## Dependencies

This module depends on the following Puppet modules:

  * Puppetlabs stdlib: https://github.com/puppetlabs/puppetlabs-stdlib
  * Onyxpoint concat: https://github.com/onyxpoint/pupmod-concat
  * templatelv: https://github.com/duritong/puppet-templatewlv

## Contributing

Feel free to fork, epand upon this module and send pull requests back
our way.

For contributions to be accepted we do require the following:

  * Code must pass without warnings through puppet-lint or have a real
    good reason as why it can't pass that check.
  * Certain manifests are extensively documented because of how important
    they are. Should your change touch these manifests you must update the
    documentation accordingly.
  * Tests must be added or changed to reflect the new behaviour and must of
    course pass. Tests can be found in the ``spec/`` directory and are written
    with the help of rspec-puppet.

## License

Copyright 2012 - 2013, Nedap Steppingstone.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

&nbsp;&nbsp;&nbsp;&nbsp;[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## Support

File an issue at: https://github.com/nedap/puppet-nginx/issues.
