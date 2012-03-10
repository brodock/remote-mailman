require 'mailman'
require 'mailman_spec_helper'
require 'fakeweb'

describe Mailman do
  include MailmanSpecHelper

  before(:each) do
    FakeWeb.clean_registry
    @mailman = Mailman.new
  end

  describe :login do
    it "should raise RuntimeError if no configuration was defined" do
      expect { @mailman.send(:login) }.to raise_error(RuntimeError)
    end

    it "should raise Mechanize::UnauthorizedError if password login fails" do
      fake_invalid_login

      @mailman.config= configuration_hash
      expect { @mailman.send(:login) }.to raise_error(Mechanize::UnauthorizedError)
    end

    it "should return true if it can log in correctly" do
      fake_login

      @mailman.config= configuration_hash
      @mailman.send(:login).should be true
    end
  end

  describe :config do
    it "should raise ArgumentError if no argument or invalid hash was informed" do
      expect { @mailman.config=() }.to raise_error(ArgumentError)
      expect { @mailman.config=({'random' => 'data'}) }.to raise_error(ArgumentError)
    end

    it "should accept a valid configuration hash" do
      expect { @mailman.config= configuration_hash }.not_to raise_error(ArgumentError)
    end
  end
end
