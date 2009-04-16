%w(rubygems sinatra haml dm-core dm-validations dm-timestamps).each{|lib| require lib}

require File.join(File.dirname(__FILE__), 'lib', 'hatchet')

set :public, 'public'
set :views,  'views'

#
# Stylesheets (fold)

# reset stylesheet
get '/stylesheets/reset.css' do
  header 'Content-Type' => 'text/css; charset=utf-8'
  css :reset
end

# main stylesheet
get '/stylesheets/screen.css' do
  header 'Content-Type' => 'text/css; charset=utf-8'
  css :screen
end

# demo stylesheet
get '/stylesheets/demo.css' do
  header 'Content-Type' => 'text/css; charset=utf-8'
  css :demo
end
# (end)


get '/' do
  
  haml :index
end

get '/signup' do
  @person = Person.new
  
  haml :signup
end

post '/signup' do
  @person = Person.new(params[:peep])
  
  if @person.save
    redirect '/'
  else
    haml :signup
  end  
end

get '/thanks' do
  
  haml :thanks
end