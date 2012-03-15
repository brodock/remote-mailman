require 'mailman'
require 'mailman_spec_helper'
require 'fakeweb'

describe Mailman do
  include MailmanSpecHelper

  before(:each) do
    FakeWeb.clean_registry
    @mailman = Mailman.new
    @mailman.config= configuration_hash
  end

  describe :login do
    it "should raise RemoteMailman::NoConfigurationError if no configuration was defined" do
      @mailman = Mailman.new
      expect { @mailman.send(:login) }.to raise_error(RemoteMailman::NoConfigurationError)
    end
    
    it "should raise RemoteMailman::InvalidPageError if wrong login page received" do
      fake_invalid_login_page
      
      expect { @mailman.send(:login) }.to raise_error(RemoteMailman::InvalidPageError)
    end

    it "should raise Mechanize::UnauthorizedError if password login fails" do
      fake_invalid_login

      expect { @mailman.send(:login) }.to raise_error(Mechanize::UnauthorizedError)
    end

    it "should return true if it can log in correctly" do
      fake_login

      @mailman.send(:login).should be true
    end
  end

  describe :config do
    it "should raise ArgumentError if no argument or invalid hash was informed" do
      @mailman = Mailman.new
      expect { @mailman.config=() }.to raise_error(ArgumentError)
      expect { @mailman.config=({'random' => 'data'}) }.to raise_error(ArgumentError)
      @mailman.config.should == nil
    end

    it "should accept a valid configuration hash" do
      expect { @mailman.config= configuration_hash }.not_to raise_error(ArgumentError)
      @mailman.config.path.should == configuration_hash['path']
      @mailman.config.password.should == configuration_hash['password']
      @mailman.config.host.should == configuration_hash['host']
    end
  end
  
  describe :members do
    before(:each) do
      fake_login
      fake_member_list
      @mailman = Mailman.new
      @mailman.config = configuration_hash
    end
    
    it "should list subscribed members with subscription details" do
      members = @mailman.members
      members.count.should == 2
      members[0].name.should == 'Member 1'
      members[0].email.should == 'member1@example.org'
      members[0].moderated.should == false
      members[0].hidden.should == false
      members[0].nomail.should == false
      
      members[1].name.should == 'Member 2'
      members[1].email.should == 'member2@example.org'
      members[1].moderated.should == true
      members[1].hidden.should == true
      members[1].nomail.should == true
    end
    
    it "should cache query in a instance variable" do
      members = @mailman.members
      @mailman.instance_variable_get('@members').should == members
    end
    
  end
end
