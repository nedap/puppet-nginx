require 'spec_helper'

describe 'nginx::configs::nxconf' do

  let(:pre_condition) {
    [ "class nginx {
        $dir_www                       = '/var/www'
        $dir_nx_conf                   = '/etc/nginx'
        $user_nx                       = 'www-data'
        $default_status                = true
        $status_allowed_ips            = ['127.0.0.1', '10.0.0.0/8']
        $workers                       = 12
        $worker_connections            = 2048
        $events_queue                  = 'epoll'
        $default_mime_type             = 'application/octet-stream'
        $server_names_hash_bucket_size = 32
        $types_hash_max_size           = 2048
        $server_tokens                 = false
        $ipv6                          = true
        $ssl_features                  = {
          'protocols'      => ['SSLv3', 'TLSv1', 'TLSv1.1', 'TLSv1.2'],
          'session_cache' => false,
          'ciphers'        => ['HIGH','!aNULL','!MD5','!SSLv2',
                        '!ADH','!eNULL','!NULL','!RC4']
        }
        $keepalive_timeout             = 25
        $sendfile                      = true
        $sendfile_max_chunk            = 0
        $tcp_nodelay                   = true
        $tcp_nopush                    = true
        $gzip                          = true
        $gzip_config                   = {
          'disable'      => 'msie6',
          'vary'         => 'on',
          'comp_level'   => '6',
          'buffers'      => '16 8k',
          'http_version' => '1.1',
          'types'        => [ 'text/plain',
                              'text/css',
                            ],
        }
      }",
      "include nginx"
  ]}

  it 'should setup nginx.conf' do
    should contain_file('/etc/nginx/nginx.conf').with({
      :owner => 'root',
      :group => 'root',
      :mode  => '0640',
      :source => /nxconf/,
    })
  end

  it 'should concat_build nxconf' do
    should contain_concat_build('nxconf').with({
      :order => ['*.conf']
    })
  end

  it 'should generate the start' do
    should contain_concat_fragment('nxconf+001-start.conf').with_content(
      /user\s+www-data;\n/
    ).with_content(
      /worker_processes\s+12;\n/
    )
  end

  it 'should generate the events section' do
    should contain_concat_fragment('nxconf+010-events-start.conf').with({
      :content => 'events {'
    })

    should contain_concat_fragment('nxconf+011-events_body.conf').with_content(
      /use\s+epoll;\n/
    ).with_content(
      /worker_connections\s+2048;\n/
    )

    should contain_concat_fragment('nxconf+019-events-end.conf').with({
      :content => '}'
    })
  end

  it 'should generate the http section' do
    should contain_concat_fragment('nxconf+020-http-start.conf').with({
      :content => 'http {',
    })

    should contain_concat_fragment('nxconf+021-http-body.conf').with_content(
      /include\s+conf\.d\/mime\.types;/
    ).with_content(
      /default_type\s+application\/octet\-stream;/
    ).with_content(
      /access_log\s+\/var\/log\/nginx\/access\.log;/
    ).with_content(
      /error_log\s+\/var\/log\/nginx\/error\.log;/
    ).with_content(
      /server_names_hash_bucket_size\s+32;/
    ).with_content(
      /types_hash_max_size\s+2048;/
    ).with_content(
      /keepalive_timeout\s+25;/
    ).with_content(
      /server_tokens off;/
    ).with_content(
      /tcp_nopush on;/
    ).with_content(
      /tcp_nodelay on;/
    ).with_content(
      /sendfile on;/
    ).with_content(
      /gzip on;/
    ).with_content(
      /gzip_disable "msie6";/
    ).with_content(
      /gzip_comp_level 6;/
    ).with_content(
      /gzip_http_version 1\.1;/
    ).with_content(
      /gzip_vary on;/
    ).with_content(
      /gzip_buffers 16 8k;/
    ).with_content(
      /gzip_types text\/plain text\/css;/
    ).with_content(
      /server \{/
    ).with_content(
      /listen\s+80\s+default_server;/
    ).with_content(
      /listen\s+\[::\]:80;/
    ).with_content(
      /server_name\s+_;/
    ).with_content(
      /root\s+\/var\/www;/
    ).with_content(
      /include\s+conf\.d\/location\.defaults;/
    ).with_content(
      /location \/ \{/
    ).with_content(
      /stub_status\s+on;/
    ).with_content(
      /access_log\s+off;/
    ).with_content(
      /log_not_found\s+off;/
    ).with_content(
      /allow\s+127.0.0.1;/
    ).with_content(
      /allow\s+10.0.0.0\/8;/
    ).with_content(
      /deny\s+all;/
    ).with_content(
      /\}\n\s+\}\n/
    )

    should contain_concat_fragment('nxconf+029-http-body-end.conf').with_content(
      /include conf\.d\/\*\.conf;/
    ).with_content(
      /include sites\-enabled\/\*;\n\}/
    )
  end

  it 'should generate the SSL configuration' do
    should contain_file('/etc/nginx/conf.d/ssl.conf').with({
      :owner => 'root',
      :group => 'root',
      :mode  => '0640',
    }).with_content(
      /ssl_prefer_server_ciphers on;/
    ).with_content(
      /ssl_ciphers\s+HIGH:!aNULL:!MD5:!SSLv2:!ADH:!eNULL:!NULL:!RC4;/
    ).with_content(
      /ssl_protocols\s+SSLv3 TLSv1 TLSv1.1 TLSv1.2;/
    ).with_content(
      /ssl_session_cache\s+off;/
    )
  end
end
