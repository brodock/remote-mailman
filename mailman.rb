#!/usr/bin/ruby
# encoding: utf-8

require 'rubygems'
require 'bundler/setup'
require 'mechanize'
require 'ostruct'

module RemoteMailman
  class InvalidPageError < StandardError; end
  class NoConfigurationError < StandardError; end
end

class Mailman < Mechanize
  def initialize()
    super
    @html_parser = Nokogiri::HTML
    self.user_agent_alias = 'Linux Mozilla'
    @logged_in = false
  end

  def config=(config={})
    unless config.is_a? Hash and config.has_key? 'host' and config.has_key? 'path' and config.has_key? 'password'
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

  def members(options = {:force => false})
    return @members if defined? @members and options['force'] == false
    @members = []
    login()
    get("#{@config.url}/members") do |members_page|
      members_page.search('//table[@width="90%"]/tr[position()>2]').each do |rows|
        member = OpenStruct.new

        columns = rows.search('td')
        member.name = columns[1].xpath('input[@type="TEXT"]').first['value']
        member.email = columns[1].xpath('a').first.children.to_s
        member.moderated = checkbox_to_bool(columns[2].xpath('center/input[@type="CHECKBOX"]').first)
        member.hidden = checkbox_to_bool(columns[3].xpath('center/input[@type="CHECKBOX"]').first)
        member.nomail = checkbox_to_bool(columns[4].xpath('center/input[@type="CHECKBOX"]').first)

        @members << member
      end
    end
    @members
  end

  private

  def login()
    return if @logged_in
    raise RemoteMailman::NoConfigurationError, "Configuration not defined" if @config.nil?
    
    get(@config.url) do |login_page|
        form = login_page.form_with(:action => "#{@config.path}")
        raise RemoteMailman::InvalidPageError.new("Invalid login page received") if form.nil?
        form.adminpw = @config.password
        form.submit
    end
    @logged_in = true
  end

  def checkbox_to_bool(element)
    element['value'] == 'on' ? true : false
  end
end
