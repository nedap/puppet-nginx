require 'spec_helper'

describe 'nginx::configs' do

  let(:pre_condition) {
    [ "class nginx {
          $dir_www                       = '/var/www'
          $dir_nx_conf                   = '/etc/nginx'
          $default_status                = true
          $status_allowed_ips            = []
          $workers                       = 12
          $worker_connections            = 2048
          $events_queue                  = 'epoll'
          $default_mime_type             = 'application/octet-stream'
          $server_names_hash_bucket_size = 32
          $types_hash_max_size           = 2048
          $server_tokens                 = false
          $ssl_features                  = {
            'protocols'      => ['SSLv3', 'TLSv1', 'TLSv1.1', 'TLSv1.2'],
            'sessions_cache' => false,
            'ciphers'        => ['HIGH','!aNULL','!MD5','!SSLv2',
                        '!ADH','!eNULL','!NULL','!RC4']
          }
          $keepalive_timeout             = 25
          $sendfile                      = true
          $sendfile_max_chunk            = 0
          $tcp_nodelay                   = true
          $tcp_nopush                    = true
          $gzip                          = true
          $gzip_config                   = {}
        }",
  "include nginx"
  ]}

  it 'should declare itself' do
    should contain_class('nginx::configs')
  end

  it 'should execute in the right order' do
    should contain_class('nginx::configs::clean')
    should contain_class('nginx::configs::scaffold')
    should contain_class('nginx::configs::nxconf')
  end
end
