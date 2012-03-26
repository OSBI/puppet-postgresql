require 'spec_helper'
require 'pp'

pgconf = Puppet::Type.type(:pgconf)

describe pgconf do
  before :each do
    @class = pgconf
    @provider = stub 'provider'
    @provider.stubs(:name).returns(:parsed)
    Puppet::Type::Pgconf.stubs(:defaultprovider).returns @provider

    @resource = @class.new({
      :name    => 'fsync',
      :value   => 'on',
      :target  => '/etc/postgresql/9.0/main/postgresql.conf'
    })
  end

  it 'should have :name as its namevar' do
    @class.key_attributes.should == [:name]
  end

  describe 'param :name' do
    it 'should be a parameter' do
      @class.attrtype(:name).should == :param
    end

    it 'should accept a name' do
      @resource[:name] = 'fsync'
      @resource[:name].should == 'fsync'
    end

    it 'should only accept a name with letters and underscore' do
      lambda { @resource[:name] = '%*#^(#$' }.should raise_error(Puppet::Error)
      lambda { @resource[:name] = 'foo bar' }.should raise_error(Puppet::Error)
      lambda { @resource[:name] = '123-456' }.should raise_error(Puppet::Error)
    end

  end

  describe 'param :value' do
    it 'should be a property' do
      @class.attrtype(:value).should == :property
    end

    it 'should accept a value' do
      @resource[:value] = 'on'
      @resource[:value].should == 'on'
    end
  end

  describe 'property :target' do
    it 'should be a property' do
      @class.attrtype(:target).should == :property
    end

    it 'should accept a target pathname' do
      @resource[:target] = '/etc/postgresql/9.0/main/postgresql.conf'
      @resource[:target].should == '/etc/postgresql/9.0/main/postgresql.conf'
    end

    it 'should set a reasonable default target' do
      pending "failed to make this work"

      @class.new({
        :name    => 'fsync',
        :value   => 'on',
        #:target  => 'undef',
      })[:target].should == '/etc/postgresql.conf'
    end

    it 'should not accept invalid path names' do
      pending "not sure if this is really testable"
    end
  end

end
