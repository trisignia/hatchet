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