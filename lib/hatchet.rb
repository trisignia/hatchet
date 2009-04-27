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
    
  def chop_ready?
    !self.kindle_email.nil?
  end
  
  has n, :chips
  
end

class Page
  include DataMapper::Resource
  
  property  :id,                  Integer,  :serial => true    # primary serial key
  property  :title,               String,   :length => 255
  property  :url,                 String,   :length => 255, :nullable => false, :unique => true
  property  :khtml,               Text
  property  :created_at,          DateTime
  property  :updated_at,          DateTime

  def chipped?
    self.khtml
  end
  
  has n, :chips

end

class Chip  
  include DataMapper::Resource
  
  property  :id,                  Integer,  :serial => true    # primary serial key
  property  :person_id,           Integer,  :nullable => false
  property  :page_id,             Integer,  :nullable => false  
  property  :attempted_sent_at,   DateTime
  property  :sent_at,             DateTime
  property  :created_at,          DateTime
  
  
  belongs_to :person
  belongs_to :page
  
end

DataMapper.auto_upgrade!
# (end)

#
# Mailers (fold)
ActionMailer::Base.template_root  = File.dirname(__FILE__) + "/../views"
ActionMailer::Base.delivery_method = :sendmail

class Notifier < ActionMailer::Base

  def kindle_email(kindle_email, page, sent_at = Time.now)
    subject     "An email from Hatchet @ #{sent_at}" 
    recipients  ["#{kindle_email}@gmail.com"]
    from        "pb@hatchetapp.com" 
    sent_on     sent_at
    attachment  :content_type => "text/html", 
                :body => page.khtml,
                :filename => "#{page.title}.html"
  end
  
end
# (end)