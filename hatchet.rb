%w(rubygems sinatra haml dm-core dm-validations dm-timestamps action_mailer).each{|lib| require lib}

require File.join(File.dirname(__FILE__), 'lib', 'hatchet')
require File.join(File.dirname(__FILE__), 'lib', 'page', 'page')
gem 'ruby-openid', '>=2.1.2'
require 'openid'
require 'openid/store/memory'

# Session needs to be after Rack::OpenID
use Rack::Session::Cookie, :key => 'rack.session',
                           :expire_after => 60*60*24*365,
                           :secret => 'n0w 1s th3 t1m3 f0r 411 g00d m3n t0 c0m3 t0 th3 a1d 0f th31r c0untry'

set :public, 'public'
set :views,  'views'

#
# OpenID (fold)
def store(store = nil)
  @store = store || OpenID::Store::Memory.new
end

def openid_consumer
  unless session = env["rack.session"]
    raise RuntimeError, "Rack::OpenID requires a session"
  end

  @openid_consumer ||= OpenID::Consumer.new(session, @store)  
end

def root_url
  request.url.match(/(^.*\/{2}[^\/]*)/)[1]
end

not_found do
 if @app
   @app.call(env)
 end
end
# (end)


#
# Actions
get '/login' do
  # session["uid"] ||= "jacob.patton@gmail.com"
  
  haml :login
end

post '/login/openid' do
  openid = params[:openid_identifier]
  begin
    oidreq = openid_consumer.begin(openid)
  rescue OpenID::DiscoveryFailure => why
    "Sorry, we couldn't find your identifier '#{openid}'"
  else
    # You could request additional information here - see specs:
    # http://openid.net/specs/openid-simple-registration-extension-1_0.html
    # oidreq.add_extension_arg('sreg','required','nickname')
    # oidreq.add_extension_arg('sreg','optional','fullname, email')
    
    # Send request - first parameter: Trusted Site,
    # second parameter: redirect target
    redirect oidreq.redirect_url(root_url, root_url + "/login/openid/complete")
  end
end

get '/login/openid/complete' do
  oidresp = openid_consumer.complete(params, request.url)

  case oidresp.status
    when OpenID::Consumer::FAILURE
      "Sorry, we could not authenticate you with the identifier '{openid}'."

    when OpenID::Consumer::SETUP_NEEDED
      "Immediate request failed - Setup Needed"

    when OpenID::Consumer::CANCEL
      "Login cancelled."

    when OpenID::Consumer::SUCCESS
      # Access additional informations:
      # puts params['openid.sreg.nickname']
      # puts params['openid.sreg.fullname']   
      
      # Startup something
      "Login successfull."  
      # Maybe something like
      # session[:user] = User.find_by_openid(oidresp.display_identifier)
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