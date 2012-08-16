require 'spec_helper'

provider_class = Puppet::Type.type(:pgconf).provider(:parsed)

describe provider_class do
  include PuppetSpec::Files

  before do
    @pgconf_class = Puppet::Type.type(:pgconf)
    @provider = @pgconf_class.provider(:parsed)
    @pgconf_file = tmpfile('pgconf')
    @provider.any_instance.stubs(:target).returns @pgconf_file
  end

  after :each do
    @provider.initvars
  end

  def mkpgconf(args)
    pgconfresource = Puppet::Type::Pgconf.new(:name => args[:name])
    pgconfresource.stubs(:should).with(:target).returns @pgconf_file

    pgconf = @provider.new(pgconfresource)
    args.each do |property,value|
      pgconf.send("#{property}=", value)
    end
    pgconf
  end

  def genpgconf(pgconf)
    @provider.stubs(:filetype).returns(Puppet::Util::FileType::FileTypeRam)
    pgconf.flush
    @provider.target_object(@pgconf_file).read
  end

  # never got this to work :-(
  #describe "general behaviour" do
  #  it_should_behave_like "all parsedfile providers", @provider
  #end

  describe "when parsing basic key/values" do

    it "should parse the key" do
      @provider.parse_line('shared_buffers = 24MB')[:name].should == 'shared_buffers'
    end

    it "should parse the value" do
      @provider.parse_line('shared_buffers = 24MB')[:value].should == '24MB'
    end
  end

  describe "when parsing special cases" do

    it "should not fail if = was omitted" do
      provider = @provider.parse_line("fsync on")
      provider[:name].should == 'fsync'
      provider[:value].should == 'on'
    end

    it "should handle extra whitespaces" do
      provider = @provider.parse_line("		fsync   =   on   ")
      provider[:name].should == 'fsync'
      provider[:value].should == 'on'
    end

    it "should skip comments" do
      provider = @provider.parse_line("# this is a comment")
      provider[:record_type].should == :comment
      provider[:line].should == "# this is a comment"
    end

    it "should skip blank lines" do
      @provider.parse_line(" ")[:record_type].should == :blank
    end

    it "should handle 'include' special keyword" do
      provider = @provider.parse_line("Include 'site.conf'")
      provider[:record_type].should == :parsed
      provider[:name].should == 'include'
      provider[:value].should == 'site.conf'
    end

  end

  describe "when dealing with values" do

    it "should lowercase uppercased keys" do
      @provider.parse_line("FSYNC = on")[:name].should == 'fsync'
    end

    it "should lowercase mixed-case keys" do
      @provider.parse_line("Fsync = on")[:name].should == 'fsync'
    end

  end

  describe "when dealing with values" do

    it "should parse a value in single quotes" do
      @provider.parse_line("enable_indexscan = 'on'")[:value].should == 'on'
    end

    it "should parse a quoted value with included quotes" do
      @provider.parse_line("archive_command = 'tar \'quoted option\''")[:value].should == 'tar \'quoted option\''
    end

    it "should parse a quoted value with double quotes inside single quotes" do
      @provider.parse_line("search_path = '\"$user\", public'")[:value].should == '"$user", public'
    end

    it "should parse a decimal value" do
      @provider.parse_line("seq_page_cost = 2.0")[:value].should == '2.0'
    end

    it "should parse a value with suffix" do
      @provider.parse_line("archive_timeout = 30s")[:value].should == '30s'
    end

    it "should parse a value with a trailing comment" do
      parsed = @provider.parse_line("archive_timeout = 30s # this is a comment")
      parsed[:value].should == '30s'
      parsed[:comment].should == 'this is a comment'
    end

  end

  describe "when writing values to postgresql.conf" do

    it "should create a simple entry" do
      pgconf = mkpgconf(
        :name   => 'shared_buffers',
        :value  => '24MB',
        :ensure => 'present'
      )
      genpgconf(pgconf).should == "shared_buffers = 24MB\n"
    end

    it "should normalize case of keys" do
      pgconf = mkpgconf(
        :name   => 'Shared_Buffers',
        :value  => '24MB',
        :ensure => 'present'
      )
      genpgconf(pgconf).should == "shared_buffers = 24MB\n"
    end

    it "should create an entry without quotes for floats" do
      pgconf = mkpgconf(
        :name   => 'bgwriter_lru_multiplier',
        :value  => '2.0',
        :ensure => 'present'
      )
      genpgconf(pgconf).should == "bgwriter_lru_multiplier = 2.0\n"
    end

    it "should create an entry without quotes for negative integers" do
      pgconf = mkpgconf(
        :name   => 'wal_buffers',
        :value  => '-1',
        :ensure => 'present'
      )
      genpgconf(pgconf).should == "wal_buffers = -1\n"
    end

    it "should create an entry with quotes if value has special characters" do
      pgconf = mkpgconf(
        :name   => 'search_path',
        :value  => '"$user", public',
        :ensure => 'present'
      )
      genpgconf(pgconf).should == "search_path = '\"$user\", public'\n"
    end

    it "should create an entry with quotes if value has dots and underscores" do
      pgconf = mkpgconf(
        :name   => 'default_text_search_config',
        :value  => 'pg_catalog.english',
        :ensure => 'present'
      )
      genpgconf(pgconf).should == "default_text_search_config = 'pg_catalog.english'\n"
    end

    it "should create an entry without = if special include directive" do
      pgconf = mkpgconf(
        :name   => 'include',
        :value  => 'site.conf',
        :ensure => 'present'
      )
      genpgconf(pgconf).should == "include 'site.conf'\n"
    end

  end

end
