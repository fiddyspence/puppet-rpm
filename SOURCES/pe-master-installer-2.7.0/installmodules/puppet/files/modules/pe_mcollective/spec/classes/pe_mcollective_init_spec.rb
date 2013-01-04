require 'spec_helper'

describe 'pe_mcollective' do
  before :all do
    @facter_facts = {
      'osfamily'              => 'RedHat',
      'lsbmajdistrelease'     => '6',
      'puppetversion'         => '2.7.6 (Puppet Enterprise 2.0.0)',
      'fact_is_puppetmaster'  => 'true',
      'fact_is_puppetconsole' => 'true',
      'fact_is_puppetagent'   => 'true',
      'fact_stomp_server'     => 'testagent',
      'fact_stomp_port'       => '6163',
    }
  end

  let :facts do
    @facter_facts
  end

  let :wrapper do
    '/etc/puppetlabs/activemq/activemq-wrapper.conf'
  end

  let :amq_xml do
    '/etc/puppetlabs/activemq/activemq.xml'
  end

  it { should contain_class 'pe_mcollective' }
  it { should contain_class 'pe_mcollective::posix' }
  it { should contain_class 'pe_mcollective::plugins' }
  it { should contain_class 'pe_mcollective::metadata' }

  describe '/opt/puppet/libexec/mcollective/mcollective' do
    it do
      should create_resource('file', '/opt/puppet/libexec/mcollective/mcollective/util').with_param('mode','0755')
    end
  end

  describe '/etc/puppetlabs/mcollective/server.cfg' do
    it do
      should contain_file('/etc/puppetlabs/mcollective/server.cfg').with_notify('Service[mcollective]')
    end
  end

  describe '#12210 ActiveMQ Clustering Class Param' do
    let :params do
      { :activemq_brokers => [ 'foo.example.com', 'bar.example.com' ] }
    end
    it 'should be a class parameter' do
      should contain_file(amq_xml).with_content(/static:\(ssl:\/\/#{params[:activemq_brokers][0]}:61616\)/)
      should contain_file(amq_xml).with_content(/static:\(ssl:\/\/#{params[:activemq_brokers][1]}:61616\)/)
    end
  end

  describe '#12210 ActiveMQ Clustering Node Param' do
    let :facts do
      @facter_facts.merge({'activemq_brokers' => 'foo.example.com,bar.example.com'})
    end
    it 'should be a class parameter' do
      should contain_file(amq_xml).with_content(/static:\(ssl:\/\/#{facts['activemq_brokers'].split(',')[0]}:61616\)/)
      should contain_file(amq_xml).with_content(/static:\(ssl:\/\/#{facts['activemq_brokers'].split(',')[1]}:61616\)/)
    end
  end

  describe '#10961 ActiveMQ Java Heap Class Param' do
    let :params do
      { :activemq_heap_mb => '1024' }
    end
    it 'should be a class parameter' do
      should contain_file(wrapper).with_content(/wrapper\.java\.initmemory=#{params[:activemq_heap_mb]}/)
      should contain_file(wrapper).with_content(/wrapper\.java\.maxmemory=#{params[:activemq_heap_mb]}/)
    end
  end

  describe '#10961 ActiveMQ Java Heap Node Param' do
    let :facts do
      @facter_facts.merge({'activemq_heap_mb' => '2048'})
    end
    it 'should be a node parameter' do
      should contain_file(wrapper).with_content(/wrapper\.java\.initmemory=#{facts['activemq_heap_mb']}/)
      should contain_file(wrapper).with_content(/wrapper\.java\.maxmemory=#{facts['activemq_heap_mb']}/)
    end
  end

  describe '#12400 SLES 11 IBM java performance' do
    let :facts do
      @facter_facts.merge({ 'osfamily' => 'Suse' })
    end
    it 'should have IBM specific entry' do
      should contain_file(wrapper).with_content(/wrapper\.java\.additional\.11=-Dcom\.ibm\.tools\.attach\.enable=no/)
    end
  end

  describe '#12400 Reverse SLES 11 IBM java performance' do
    it 'should not have IBM specific entry' do
      should_not contain_file(wrapper).with_content(/wrapper\.java\.additional\.11=-Dcom\.ibm\.tools\.attach\.enable=no/)
    end
  end

  context 'windows node catalog (#12357)' do
    let :facts do
      @facter_facts.merge({ 'osfamily' => 'windows' })
    end
    it { should_not contain_class 'pe_mcollective::posix' }
    it { should_not contain_service 'mcollective' }
  end

  context 'FOSS (un-supported) Puppet Agent' do
    let :facts do
      @facter_facts.merge({ 'puppetversion' => '2.7.6' })
    end
    it { should_not contain_class 'pe_mcollective::posix' }
    it { should_not contain_service 'mcollective' }
    it { should contain_notify 'pe_mcollective-un_supported_platform' }
  end

  context 'FOSS Agent -- Notifications Off' do
    let :facts do
      @facter_facts.merge({ 'puppetversion' => '2.7.6', 'warn_on_nonpe_agents' => 'false' })
    end
    it { should_not contain_class 'pe_mcollective::posix' }
    it { should_not contain_service 'mcollective' }
    it { should_not contain_notify 'pe_mcollective-un_supported_platform' }
  end
end
