require 'spec_helper'

describe 'nginx::resource::confd' do
  let(:pre_condition) {
    [ "class nginx {
       $dir_nx_conf = '/etc/nginx'
    }",
    "include nginx"
    ]
  }

  let(:title) { 'test' }

  context 'with content' do
    let :params do {
      :content => 'Hi there, this is text',
    } end

    it 'resource file test.conf with content from params' do
      should contain_file('/etc/nginx/conf.d/test.conf').with({
        :ensure => 'file',
        :owner   => 'root',
        :group   => 'root',
        :mode    => '0640',
        :source  => nil,
        :require => 'Class[Nginx::Configs]',
        :notify  => 'Class[Nginx::Services]',
        :content => /Hi there, this is text/,
      })
    end
  end

  context 'with source' do
    let :params do {
      :source => 'puppet:///some/other/module',
    } end

    it 'file resource test.conf with source set from params' do
      should contain_file('/etc/nginx/conf.d/test.conf').with({
        :ensure => 'file',
        :owner   => 'root',
        :group   => 'root',
        :mode    => '0640',
        :content => nil,
        :source  => 'puppet:///some/other/module',
        :require => 'Class[Nginx::Configs]',
        :notify  => 'Class[Nginx::Services]',
      })
    end
  end

  context 'with ensure=false' do
    let :params do {
      :enable => false,
    } end

    it 'file resource test.conf with ensure=absent' do
      should contain_file('/etc/nginx/conf.d/test.conf').with_ensure('absent')
    end
  end

  context 'without source or content' do
    it 'breaks and tells you you are not playing nice' do
      expect { subject }.to raise_error(/Need either a content or a source/)
    end
  end
end
