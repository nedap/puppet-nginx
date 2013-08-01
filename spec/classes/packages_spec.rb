require 'spec_helper'

describe 'nginx::packages' do
  it 'should declare itself' do
    should contain_class('nginx::packages')
  end
end
