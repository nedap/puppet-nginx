require 'spec_helper'

describe 'nginx::services' do
  it 'should declare itself' do
    should contain_class('nginx::services')
  end

  context 'without parameters' do
    it do
      should contain_service('nginx').with({
        :ensure => 'running',
        :enable => true,
        :hasrestart => true,
        :hasstatus => true,
        :restart => 'service nginx reload',
      })
    end
  end
end
