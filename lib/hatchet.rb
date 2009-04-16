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
ActionMailer::Base.template_root = File.expand_path(".")
ActionMailer::Base.delivery_method = :sendmail
ActionMailer::Base.sendmail_settings = {
  :location => "/usr/sbin/sendmail",
  :arguments => "-t" 
}

class Notifier < ActionMailer::Base
  def hello_world(email, sent_at = Time.now)
    recipients email
    from "sinatra-app@do-not-reply.com" 
    subject "An email from Sinatra @ #{sent_at}" 
    part :content_type => "text/plain", :body => "Hello, World" 
  end
end
# (end)