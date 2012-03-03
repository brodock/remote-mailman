#!/usr/bin/ruby
# encoding: utf-8

require 'rubygems'
require 'mechanize'
require 'ostruct'

class Mailman < Mechanize
  def initialize()
    super
    @html_parser = Nokogiri::HTML
    self.user_agent_alias = 'Linux Mozilla'
    @logged_in = false
  end

  def config=(config={})
    unless config.has_key? 'host' and config.has_key? 'path' and config.has_key? 'password'
      raise ArgumentError, "Invalid configuration hashes"
    end
  
    @config = OpenStruct.new
    @config.host = config['host']
    @config.path = config['path']
    @config.url = "http://#{@config.host}#{@config.path}"
    @config.password = config['password']
    @config.freeze
  end

  def config()
    @config
  end

  def members()
    members = []
    login()
    get("#{@config.url}/members") do |members_page|
      members_page.search('//table[@width="90%"]/tr[position()>2]/td[2]').each do |td_tags|
        member = OpenStruct.new
        member.name = td_tags.xpath('input[@type="TEXT"]').first['value']
        member.email = td_tags.xpath('a').first.children.to_s
        members << member
      end
    end
    members
  end

  private

  def login()
    return if @logged_in
    raise RuntimeError, "Configuration not defined" if @config.nil?
    get(@config.url) do |login_page|
      form = login_page.form_with(:action => "#{@config.path}")
      form.adminpw = @config.password
      form.submit
    end
    @logged_in = true
  end

end
