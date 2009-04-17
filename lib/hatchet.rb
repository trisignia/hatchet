#
# Database connection (fold)
configure :development do
  DataMapper.setup(:default, {
    :adapter  => 'mysql',
    :host     => 'localhost',
    :username => 'root' ,
    :password => '',
    :database => 'hatchet_development'})  

  DataMapper::Logger.new(STDOUT, :debug)
end

configure :test do
  DataMapper.setup(:default, {
    :adapter  => 'mysql',
    :host     => 'localhost',
    :username => 'root' ,
    :password => '',
    :database => 'hatchet_test'})  

  DataMapper::Logger.new(STDOUT, :debug)
end

configure :production do
  DataMapper.setup(:default, {
    :adapter  => 'mysql',
    :host     => 'localhost',
    :username => 'rails' ,
    :password => '12rAils*',
    :database => 'hatchet_production'})  
end
# (end)

#
# Error-handling (fold)
error do
  e = request.env['sinatra.error']
  puts e.to_s
  puts e.backtrace.join("\n")
  "Application error"
end
# (end)

#
# Models (fold)
class Person
  include DataMapper::Resource
  
  property  :id,                  Integer,  :serial => true    # primary serial key
  property  :openid,              String,   :length => 255, :nullable => false, :unique => true
  property  :kindle_email,        String
  property  :created_at,          DateTime
  property  :updated_at,          DateTime
  
end

class Page
  include DataMapper::Resource
  
  property  :id,                  Integer,  :serial => true    # primary serial key
  # property  :url,                 String,   :nullable => false, :unique => true
  # property  :kindle_html,         Text,     :nullable => false
  property  :uid,                 String,   :nullable => false
  property  :created_at,          DateTime
  property  :updated_at,          DateTime
  
  def uid
    self.uid ||= "foobar"
  end
  
  # set uid to something unique
  # before :create do  
  #   Page.new(self.url, self.uid)
  # end
  
end

DataMapper.auto_upgrade!
# (end)

#
# Mailers (fold)
ActionMailer::Base.template_root  = File.dirname(__FILE__) + "/../views"
ActionMailer::Base.delivery_method = :sendmail

class Notifier < ActionMailer::Base

  def kindle_email(sent_at = Time.now)
    subject     "An email from Hatchet @ #{sent_at}" 
    recipients  ['jacob.patton@gmail.com']
    from        "pb@hatchetapp.com" 
    sent_on     sent_at
    attachment  :content_type => "text/html", 
                :body => File.read(File.dirname(__FILE__) + "/../tmp/pages/test.html"),
                :filename => "kindling.html"                
  end
  
end
# (end)