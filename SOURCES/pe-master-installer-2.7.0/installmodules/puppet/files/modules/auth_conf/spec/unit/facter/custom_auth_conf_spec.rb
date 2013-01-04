
require 'spec_helper'

describe 'whether a custom auth_conf file is in use' do

  fixtures_path = File.join(File.dirname(__FILE__), '..', '..', 'fixtures', 'unit', 'facter', 'custom_auth_conf')

  after do
    Facter.clear
  end

  it 'when the file does not exist' do
    File.stubs(:exists?).with('/etc/puppet/auth.conf').returns(false)

    Facter.value(:custom_auth_conf).should == 'false'
  end

  describe 'using Puppet Enterprise' do

    before do
      Facter.fact('puppetversion').stubs(:value).returns('2.7.19 (Puppet Enterprise 2.6.1)')
    end

    it 'should look for auth.conf in the correct place' do
      File.expects(:exists?).with('/etc/puppetlabs/puppet/auth.conf')

      Facter.value(:custom_auth_conf)
    end
  end

  describe 'using open source Puppet' do

    before do
      Facter.fact('puppetversion').stubs(:value).returns('2.7.19')
    end

    it 'should look for auth.conf in the correct place' do
      File.expects(:exists?).with('/etc/puppet/auth.conf')

      Facter.value(:custom_auth_conf)
    end
  end

  describe "when auth.conf is managed by Puppet" do
    before do
      File.stubs(:exists?).with('/etc/puppet/auth.conf').returns(true)
    end

    it "should return false" do
      File.stubs(:read).returns('# THIS FILE IS MANAGED BY PUPPET')

      Facter.value(:custom_auth_conf).should == 'false'
    end
  end

  describe "when auth.conf is unmodified" do
    before do
      File.stubs(:exists?).with('/etc/puppet/auth.conf').returns(true)
    end

    unmodified_auth_confs = Dir.new("#{fixtures_path}/unmodified").
          entries().
          reject { |entry| FileTest.directory? entry }

    unmodified_auth_confs.each do |file|
      describe "when using #{file} as a template" do
        it "should return false" do
          contents = File.read("#{fixtures_path}/unmodified/#{file}")

          File.stubs(:read).returns(contents)

          Facter.value(:custom_auth_conf).should == 'false'
        end
      end
    end
  end

  describe "when auth.conf is modified" do
    before do
      File.stubs(:exists?).with('/etc/puppet/auth.conf').returns(true)
    end

    modified_auth_confs = Dir.new("#{fixtures_path}/modified").
          entries().
          reject { |entry| FileTest.directory? entry }

    modified_auth_confs.each do |file|
      describe "when using #{file} as a template" do
        it "should return true" do
          contents = File.read("#{fixtures_path}/modified/#{file}")

          File.stubs(:read).returns(contents)

          Facter.value(:custom_auth_conf).should == 'true'
          end
      end
    end
  end
end