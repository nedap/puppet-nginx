require 'spec_helper'

describe 'nginx' do

  describe 'on Debian' do
    let :facts do
      { :osfamily => 'Debian',
        :processorcount => '12',
      }
    end

    context 'with valid parameters' do
      it 'should contain class nginx' do
        should contain_class('nginx')
      end

      it 'should chain child classes in the right order' do
        should contain_class('nginx::packages').with({:before => 'Class[Nginx::Configs]',})
        should contain_class('nginx::configs').with({:before => 'Class[Nginx::Services]'})
        should contain_class('nginx::services').with({:before => 'Class[Nginx]'})
      end
    end
  end


  describe 'on unsupported' do
    let :facts do
      { :osfamily => 'Little Red Riding Hood' }
    end

    it 'should fail' do
      expect { subject }.to raise_error(/osfamily Little Red Riding Hood is not supported/)
    end
  end
end
