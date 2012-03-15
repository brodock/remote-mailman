module MailmanSpecHelper
  def configuration_hash
    {'host' => 'localhost', 'path' => '/admin.cgi/my-awesome-list', 'password' => 'myawesomepassword'}
  end

  def fake_login
    FakeWeb.register_uri(:get, 'http://localhost/admin.cgi/my-awesome-list', :body => get_page_login, :content_type => 'text/html')
    FakeWeb.register_uri(:post, 'http://localhost/admin.cgi/my-awesome-list', :content_type => 'text/html')
  end

  def fake_invalid_login
    FakeWeb.register_uri(:get, 'http://localhost/admin.cgi/my-awesome-list', :body => get_page_login, :content_type => 'text/html')
    FakeWeb.register_uri(:post, 'http://localhost/admin.cgi/my-awesome-list', :body => get_page_login, :status => ["401", "Unauthorized"], :content_type => 'text/html')
  end
  
  def fake_invalid_login_page
    FakeWeb.register_uri(:get, 'http://localhost/admin.cgi/my-awesome-list', :body => '<html><body>Can\'t touch me</body></html>', :content_type => 'text/html')
  end
  
  def fake_member_list
    FakeWeb.register_uri(:get, 'http://localhost/admin.cgi/my-awesome-list/members', :body => get_page_members, :content_type => 'text/html')
  end
  
  def method_missing(method, *args)
    if method.to_s =~ /^get_page_(.+)$/
      filename = File.expand_path(File.join(File.dirname(__FILE__), 'templates', "#{$1}.html"))
      if File.exist? filename
        File.open filename
      else
        super
      end
    else
      super
    end
  end

end
