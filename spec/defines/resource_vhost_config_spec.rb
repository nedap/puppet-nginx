require 'spec_helper'

describe 'nginx::resource::vhost::config' do
  let(:pre_condition) {
    [ "class nginx {
       $dir_nx_conf = '/etc/nginx'
    }",
    "include nginx",
    "nginx::resource::vhost { 'test':
       server_name => 'test.example.com',
     }",
    ]
  }

  let(:title) { 'test_partial' }

  context 'without content' do
    let :params do {
      :target => 'test',
      :order  => '001',
    } end

    it 'tells you content is a required parameter' do
      expect { subject }.to raise_error(/Must pass content/)
    end
  end

  context 'without target' do
    let :params do {
      :order  => '001',
      :content => 'Greetings, programs!',
    } end

    it 'tells you target is a required parameter' do
      expect { subject }.to raise_error(/Must pass target/)
    end
  end

  context 'without order' do
    let :params do {
      :target => 'test',
      :content => 'Greetings, programs!',
    } end

    it 'tells you order is a required parameter' do
      expect { subject }.to raise_error(/Must pass order/)
    end
  end

  context 'with all required parameters' do
    let :params do {
      :target  => 'test',
      :order   => '001',
      :content => 'Greetings, programs!',
    } end

    it 'contains the concat fragment' do
      should contain_concat_fragment(
        "#{params[:target]}+#{params[:order]}-#{title}.conf"
      ).with_content('Greetings, programs!')
    end
  end
end
