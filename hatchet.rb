%w(rubygems sinatra haml dm-core dm-validations dm-timestamps action_mailer).each{|lib| require lib}

require File.join(File.dirname(__FILE__), 'lib', 'hatchet')
require File.join(File.dirname(__FILE__), 'lib', 'page', 'page')
require File.join(File.dirname(__FILE__), 'lib', 'rack-openid', 'lib', 'rack', 'openid')

use Rack::OpenID

# Session needs to be after Rack::OpenID
use Rack::Session::Cookie

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


get '/login' do
  
  haml :index
end

post '/login' do  
  if resp = request.env["rack.openid.response"]
    if resp.status == :success
      "Welcome: #{resp.display_identifier}"
    else
      "Error: #{resp.status}"
    end
  else
    # format params to process Gmail addresses as OpenIDs
    if params["openid_identifier"] =~ /gmail.com$/
      params["openid_identifier"] = 'https://www.google.com/accounts/o8/id'
    end
    header 'WWW-Authenticate' => Rack::OpenID.build_header(
      :identifier => params["openid_identifier"]
    )
    throw :halt, [401, 'got openid?']
  end
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

get '/chop' do

  @url = params[:url]
  
  # process page via bj (maybe?)
  Page.new(@url)
  
  # send page via email
  Notifier.deliver_kindle_email
  
end