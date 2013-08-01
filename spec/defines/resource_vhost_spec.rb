require 'spec_helper'

# This set of tests does not cover all scenario's
# but should cover the most common ones. Ideally we'd be
# able to test every template partial independently of the
# rest.

describe 'nginx::resource::vhost' do
  let :pre_condition do
    [ "class nginx {
       $dir_nx_conf = '/etc/nginx'
    }",
    "include nginx",
    ]
  end

  let :title do 'some_vhost' end
  server_name = 'example.com'


  context 'without server_name' do
    it 'tells you server_name is a required parameter' do
      expect { subject }.to raise_error(/Must pass server_name/)
    end
  end

  context 'server_name=example.com' do
    let :params do {
      :server_name => server_name,
    } end

    it 'sets up concat build' do
      should contain_concat_build(title).with_order(['*.conf'])
    end

    it 'does not build the upstream configuration block' do
      should_not contain_concat_fragment("#{title}+000-upstream_start.conf")
      should_not contain_concat_fragment("#{title}+099-upstream_end.conf")
    end

    it 'builds the http configuration block' do
      should contain_concat_fragment("#{title}+100-http_start.conf").with_content('server {')
      should contain_concat_fragment("#{title}+110-http_body.conf").with_content(
        /listen\s+80;/
      ).with_content(
        /listen\s+\[::\]:80;/
      ).with_content(
        /access_log\s+ \/var\/log\/nginx\/example\.com_access.log;/
      ).with_content(
        /error_log\s+ \/var\/log\/nginx\/example\.com_error.log;/
      ).with_content(
        /include\s+conf.d\/location\.defaults;/
      ).with_content(
        /root\s+\/var\/www\/example\.com;/
      )
      should contain_concat_fragment("#{title}+199-http_end.conf").with_content('}')
    end

    it 'does not build the https configuration block' do
      should_not contain_concat_fragment("#{title}+200-https_start.conf")
      should_not contain_concat_fragment("#{title}+210-https_body.conf")
      should_not contain_concat_fragment("#{title}+299-https_end.conf")
    end

    it 'creates the configuration file based on the concat_build' do
      should contain_file("/etc/nginx/sites-available/#{title}.conf").with({
        :ensure => 'file',
        :owner  => 'root',
        :group  => 'root',
        :mode   => '0644',
        :notify => 'Class[Nginx::Services]',
      })
    end

    it 'symlinks the configuration file and reloads nginx' do
      should contain_file("/etc/nginx/sites-enabled/#{title}.conf").with({
        :ensure => 'link',
        :target => "/etc/nginx/sites-available/#{title}.conf",
        :notify => 'Class[Nginx::Services]',
      })
    end
  end

  context 'upstream=true' do
    let :params do {
      :server_name => server_name,
      :upstream    => true,
    } end

    it 'builds the upstream configuration block' do
      should contain_concat_fragment("#{title}+000-upstream_start.conf").with_content('upstream {')
      should contain_concat_fragment("#{title}+099-upstream_end.conf").with_content('}')
    end
  end

  context 'enable=false' do
    let :params do {
      :server_name => server_name,
      :enable      => false,
    } end

    it 'removes symlink from sites-enabled and reload nginx' do
      should contain_file("/etc/nginx/sites-enabled/#{title}.conf").with({
        :ensure => 'absent',
        :target => "/etc/nginx/sites-available/#{title}.conf",
        :notify => 'Class[Nginx::Services]',
      })
    end
  end

  context 'enable=true, purge=true' do
    let :params do {
      :server_name => server_name,
      :purge       => true,
    } end

    it 'throws an error, cannot purge and enable' do
      expect { subject }.to raise_error(/purge the configuration file but leave the symlink/)
    end
  end

  context 'enable=false, purge=true' do
    let :params do {
      :server_name => server_name,
      :enable      => false,
      :purge       => true,
    } end

    it 'does not setup the concat build or fragments' do
      should_not contain_concat_build(title).with_order(['*.conf'])
      should_not contain_concat_fragment("#{title}+000-upstream_start.conf")
      should_not contain_concat_fragment("#{title}+099-upstream_end.conf")
      should_not contain_concat_fragment("#{title}+100-http_start.conf")
      should_not contain_concat_fragment("#{title}+110-http_body.conf")
      should_not contain_concat_fragment("#{title}+199-http_end.conf")
      should_not contain_concat_fragment("#{title}+200-https_start.conf")
      should_not contain_concat_fragment("#{title}+210-https_body.conf")
      should_not contain_concat_fragment("#{title}+299-https_end.conf")
      should_not contain_file("/etc/nginx/sites-available/#{title}.conf").with({
        :require => [
          'Class[Nginx::Configs]',
          "Concat_build[#{title}]",
        ]
      })
      should contain_file("/etc/nginx/sites-available/#{title}.conf").with({
        :require => 'Class[Nginx::Configs]',
      })
    end

    it 'removes the configuration file from sites-available' do
      should contain_file("/etc/nginx/sites-available/#{title}.conf").with({
        :ensure => 'absent',
        :notify => 'Class[Nginx::Services]',
      })
    end

    it 'removes the symlink from sites-enabled and reloads nginx' do
      should contain_file("/etc/nginx/sites-enabled/#{title}.conf").with({
        :ensure => 'absent',
        :notify => 'Class[Nginx::Services]',
      })
    end
  end

  context 'ssl=true' do
    context 'ssl_key=undef' do
      let :params do {
        :server_name => server_name,
        :ssl => true,
      } end
      
      it 'throws an error about ssl_key not being provided' do
        expect { subject }.to raise_error(/\$ssl_key if \$ssl/)
      end
    end

    context 'ssl_cert=undef' do
      let :params do {
        :server_name => server_name,
        :ssl => true,
        :ssl_key => 'relative_to_nginx_conf_dir_compile_option.key',
      } end
      
      it 'throws an error about ssl_cert not being provided' do
        expect { subject }.to raise_error(/\$ssl_cert if \$ssl/)
      end
    end

    context 'ssl_cert=ssl/key.crt ssl_key=ssl/key.pem' do
      let :params do {
        :server_name => server_name,
        :ssl         => true,
        :ssl_cert    => 'ssl/key.crt',
        :ssl_key     => 'ssl/key.pem',
      } end
      
      it 'redirects all traffic to https' do
        should contain_concat_fragment("#{title}+110-http_body.conf").with_content(
          /rewrite\s+\^\/\(\.\*\)\s+example\.com\/\$1 permanent;/
        )
      end

      it 'builds a server block listening for SSL connections' do
        should contain_concat_fragment("#{title}+200-https_start.conf").with_content('server {')
        should contain_concat_fragment("#{title}+210-https_body.conf").with_content(
          /listen\s+443;/
        ).with_content(
          /listen\s+\[::\]:443;/
        ).with_content(
          /access_log\s+ \/var\/log\/nginx\/example\.com_access.log;/
        ).with_content(
          /error_log\s+ \/var\/log\/nginx\/example\.com_error.log;/
        ).with_content(
          /include\s+conf.d\/location\.defaults;/
        ).with_content(
          /root\s+\/var\/www\/example\.com;/
        ).with_content(
          /ssl_certificate\s+ssl\/key\.crt;/
        ).with_content(
          /ssl_certificate_key\s+ssl\/key\.pem;/
        ).with_content(
          /add_header\s+Strict-Transport-Security "max-age=31536000; includeSubdomains";/
        )
        should contain_concat_fragment("#{title}+299-https_end.conf").with_content('}')
      end
    end
  end

  context 'ipv6=false' do
    let :params do {
      :server_name => server_name,
      :ipv6 => false,
    } end

    it 'does not listen on ipv6' do
       should_not contain_concat_fragment("#{title}+110-http_body.conf").with_content(
          /listen\s+\[::\]:80;/
        )
    end
  end

  context "error_pages is a populated hash" do
    context "redirect_to_https=false" do
      let :params do {
        :server_name => server_name,
        :redirect_to_https => false,
        :error_pages => {
          '404' => '404.html',
          '500' => '500.html',
        },
      } end

      it 'generates the erorr_pages directives' do
        should contain_concat_fragment("#{title}+110-http_body.conf").with_content(
          /error_page 404 404\.html;/
        ).with_content(
          /error_page 500 500\.html;/
        )
      end
    end
    context "redirect_to_https=true, ssl=true" do
      let :params do {
        :server_name => server_name,
        :ssl         => true,
        :ssl_cert    => 'ssl/key.crt',
        :ssl_key     => 'ssl/key.pem',
        :redirect_to_https => true,
        :error_pages => {
          '404' => '404.html',
          '500' => '500.html',
        },
      } end

      it 'generates the erorr_pages directives' do
        should contain_concat_fragment("#{title}+210-https_body.conf").with_content(
          /error_page 404 404\.html;/
        ).with_content(
          /error_page 500 500\.html;/
        )
      end
    end
  end
end
