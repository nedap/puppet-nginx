require 'spec_helper'

describe 'nginx::configs::scaffold' do
  let(:pre_condition) {
    [ "class nginx {
       $dir_nx_conf = '/etc/nginx'
       $dir_www = '/var/www'
    }",
    "include nginx"
  ]
  }

  it 'should declare itself' do
    should contain_class('nginx::configs::scaffold')
  end

  it 'should set up the docroot and error_pages' do
    should contain_file('/var/www').with({
      :ensure => 'directory',
      :owner => 'root',
      :group => 'root',
      :mode => '0644',
    })

    should contain_file('/var/www/error_pages').with({
      :ensure => 'directory',
      :source => 'puppet:///modules/nginx/error_pages',
      :recurse => true,
      :purge => true,
      :owner => 'root',
      :group => 'root',
      :mode => '0644',
    })
  end

  it 'should setup the nginx configuration structure' do
    should contain_file('/etc/nginx/ssl').with({
      :ensure => 'directory',
      :owner => 'root',
      :group => 'root',
      :mode => '0640',
    })

    should contain_file('/etc/nginx/conf.d').with({
      :ensure => 'directory',
      :source => 'puppet:///modules/nginx/conf.d',
      :recurse => true,
      :purge => true,
      :owner => 'root',
      :group => 'root',
      :mode => '0640',
    })
  end
end
