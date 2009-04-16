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
  
  property :id,                   Integer,  :serial => true    # primary serial key
  property :first_name,           String,   :nullable => false
  property :last_name,            String,   :nullable => false
  property :organization,         String  
  property :email,                String,   :nullable => false, :unique => true, :format => :email_address
  property :phone,                String
  property :address_one,          String
  property :address_two,          String
  property :city,                 String
  property :state,                String
  property :zip,                  String
  property :created_at,           DateTime
  property :updated_at,           DateTime

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
    recipients  ['jacob.patton@kindle.com', 'jacob.patton@gmail.com']
    from        "paulbunyan@hatchetapp.com" 
    sent_on     sent_at
    attachment  :content_type => "text/html", 
                :body => File.read(File.dirname(__FILE__) + "/../tmp/pages/test.html"),
                :filename => "kindling.html"                
  end
  
end
# (end)