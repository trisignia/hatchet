%w(rubygems sinatra haml dm-core dm-validations dm-timestamps action_mailer andand).each{|lib| require lib}

# $: << File.dirname(__FILE__) + "/lib"
require 'lib/hatchet'
require 'lib/chipper/chipper'

gem     'ruby-openid', '>=2.1.2'
require 'openid'
require 'openid/store/memory'

# expire session cookies in one year
use Rack::Session::Cookie, :key => 'rack.session',
                           :expire_after => 60*60*24*365,
                           :secret => 'n0w 1s th3 t1m3 f0r 411 g00d m3n t0 c0m3 t0 th3 a1d 0f th31r c0untry'

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

def logged_in?
  if session[:openid]    
    true
  else
    false
  end
end

def login_required
  session[:redirect_path] = env['REQUEST_URI']
  
  unless logged_in?
    flash[:error] = "You must be logged-in to view the page you requested."
    redirect '/' 
  end
end

def current_person
  Person.first(:openid => session[:openid])
end

def flash
  session[:flash] = {} if session[:flash] && session[:flash].class != Hash
  session[:flash] ||= {}
end

def clear_flash_and_render_haml(*args)
  myhaml = haml(*args)
  flash.clear
  myhaml
end
# (end)

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
# (end)

#
# Actions

# homepage
get '/' do
  @id = "home"
  
  clear_flash_and_render_haml :index
end

# process OpenID login
post '/login' do
  openid = params[:openid_identifier]
  
  # create OpenID url for Google & Yahoo email addresses
  if openid =~ /@gmail.com$/
    openid = "https://www.google.com/accounts/o8/id" 
  elsif openid =~ /@yahoo.com$/
    openid = "http://yahoo.com/"
  end
  
  begin
    oidreq = openid_consumer.begin(openid)
  rescue OpenID::DiscoveryFailure => why
    flash[:error] = "Sorry, we couldn't find your identifier '#{openid}'"

    redirect '/'
  else
    redirect oidreq.redirect_url(root_url, root_url + "/login/complete")
  end
end

# login completed, redirect appropriately
get '/login/complete' do
  @oidresp = openid_consumer.complete(params, request.url)

  case @oidresp.status
    when OpenID::Consumer::FAILURE
      flash[:error] = "Sorry, we could not authenticate you with the identifier '{openid}'."
      
      redirect '/'
    when OpenID::Consumer::SETUP_NEEDED
      flash[:error] = "Immediate request failed - Setup Needed"

      redirect '/'
    when OpenID::Consumer::CANCEL
      flash[:error] = "Login cancelled."

      redirect '/'
    when OpenID::Consumer::SUCCESS
      session[:openid] = @oidresp.display_identifier
      @person = Person.first_or_create(:openid => session[:openid])
      
      # redirect to the proper location
      if redirect_path = session[:redirect_path]
        redirect redirect_path
      elsif @person.chop_ready?
        redirect '/'
      else
        redirect '/next'
      end
  end
end

# complete signup (form to add kindle email)
get '/next' do
  login_required
  
  redirect '/bookmarklets' if current_person.chop_ready?
  
  haml :next
end

# add kindle email to user record & redirect to bookmarklets page
post '/next' do
  login_required
  
  @person = current_person
  @person.update_attributes(:kindle_email => params[:kindle_email])
  
  redirect '/bookmarklets'
end

# logout (destroy session)
get '/logout' do
  session[:openid] = nil

  flash[:notice] = "You have been logged out."
  redirect '/'
end

# display bookmarklet link
get '/bookmarklets' do
  
  haml :bookmarklets
end

# need some help?  howto & update your kindle email
get '/help' do
  login_required
  
  haml :help
end

# destroy a user's account
get '/cancel' do
  login_required
    
  if current_person.destroy  
    session[:redirect_path] = nil
    flash[:notice]          = "Your account has been deleted."
    session[:openid]        = nil    
    redirect '/'
  end
end

# bookmarklet page -- TODO: style this page a bit, create rake test for chopping
get '/chop' do
  login_required
  
  redirect '/next' unless current_person.chop_ready?
  
  session[:redirect_path] = nil

  @page = Page.first_or_create(:url => params[:url], :title => params[:title])
  @chip = Chip.create(:person => current_person, :page => @page)
  
  haml :chop, {:layout => false}
end