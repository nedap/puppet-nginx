require 'spec_helper'

describe 'nginx::configs::clean' do
  let(:pre_condition) {
    [ "class nginx {
       $dir_nx_conf = '/etc/nginx'
    }",
    "include nginx"
  ]
  }

  it 'should declare itself' do
    should contain_class('nginx::configs::clean')
  end

  it 'should clean up the package cruft' do
    should contain_file('/etc/nginx').with({
      :ensure => 'directory',
      :recurse => true,
      :force   => true,
      :purge   => true,
    })

    should contain_file('/etc/nginx/sites-available').with({
      :ensure => 'directory',
      :recurse => true,
      :force   => true,
      :purge   => true,
    })

    should contain_file('/etc/nginx/sites-enabled').with({
      :ensure => 'directory',
      :recurse => true,
      :force   => true,
      :purge   => true,
    })
  end
end
