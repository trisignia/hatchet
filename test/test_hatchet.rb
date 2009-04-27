require 'test_helper'

class HatchetTest < Test::Unit::TestCase

=begin
  # homepage
  get '/' do
    @class = "home"
    haml :index
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
      "Sorry, we couldn't find your identifier '#{openid}'"
    else
      redirect oidreq.redirect_url(root_url, root_url + "/login/complete")
    end
  end

  # login completed, redirect appropriately
  get '/login/complete' do
    oidresp = openid_consumer.complete(params, request.url)

    case oidresp.status
      when OpenID::Consumer::FAILURE
        "Sorry, we could not authenticate you with the identifier '{openid}'."

      when OpenID::Consumer::SETUP_NEEDED
        "Immediate request failed - Setup Needed"

      when OpenID::Consumer::CANCEL
        "Login cancelled."

      when OpenID::Consumer::SUCCESS
        session[:openid] = oidresp.display_identifier
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

    # redirect '/bookmarklets' if current_person.chop_ready?

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

    redirect '/'
  end

  # display bookmarklet link
  get '/bookmarklets' do

    haml :bookmarklets
  end

  # need some help?  howto & update your kindle email
  get '/help' do

    haml :help
  end

  # destroy a user's account
  get '/cancel' do
    login_required

    # TODO: how to destroy a record with DataMapper?
    current_person.destroy
    # TODO: how to set the flash in Sinatra?

    redirect '/'
  end

  # bookmarklet page -- TODO: style this page a bit, create rake test for chopping
  get '/chop' do
    
=end

  context "Hatchet" do
    
    context "with an un logged in user" do

      context "get /" do
        setup do
          get '/'
        end

        should "respond" do
          assert_equal 200, response.status
        end
      end

      context "post /login without params" do
        setup do
          post '/login', :openid_identifier => nil
        end

        should "respond with a redirect" do
          assert_equal 302, response.status
        end
        
        should "set the flash" do
          # FIXME
          # flunk
        end
      end
      
      context "get /login/complete" do
        setup do
          get '/login/complete'
        end
        
        should "respond successfully" do
          assert_equal 200, response.status
        end

        should "respond with an error" do
          assert response.body =~ /Sorry, we could not authenticate you with the identifier/
        end
      end
      
      context "get /next" do
        setup do
          get '/next'
          follow!
        end

        should "redirect to homepage" do
          doc = Hpricot.parse(response.body)
          assert_equal('home', doc.at("body")['id'])
        end
      end
      
      context "post /next" do
        setup do
          post '/next'
          follow!
        end

        should "redirect to homepage" do
          doc = Hpricot.parse(response.body)
          assert_equal('home', doc.at("body")['id'])
        end
      end
      
      context "get /logout" do
        setup do
          get '/logout'
          follow!
        end

        should "redirect to homepage" do
          doc = Hpricot.parse(response.body)
          assert_equal('home', doc.at("body")['id'])
        end
      end
      
      context "get /bookmarklets" do
        setup do
          get '/bookmarklets'
        end

        should "response successfully" do
          assert_equal(200, response.status)          
        end

        should "display the bookmarklets link" do
          doc = Hpricot.parse(response.body)
          assert_equal('Send this page to my Kindle', (doc/:a).first.attributes['title'])
        end
      end
      
      context "get /help" do
        setup do
          get '/help'
          follow!
        end

        should "redirect to homepage" do
          doc = Hpricot.parse(response.body)
          assert_equal('home', doc.at("body")['id'])
        end
      end
      
      context "get /cancel" do
        setup do
          get '/cancel'
          follow!
        end

        should "redirect to homepage" do
          doc = Hpricot.parse(response.body)
          assert_equal('home', doc.at("body")['id'])
        end
      end
      
      context "get /chop" do
        setup do
          get '/chop'
          follow!
        end

        should "redirect to homepage" do
          doc = Hpricot.parse(response.body)
          assert_equal('home', doc.at("body")['id'])
        end
      end
  
    end
    
    context "with a logged in user" do
      context "get /" do
        setup do
          get '/'
        end

        should "respond" do
          assert_equal(200, @response.status)
        end
      end

      # TODO: mock the OpenID login process here
      context "post /login" do
        setup do          
          # @app = Sinatra::Application
          # @fake_oid = Object.new
          # @app.stubs(:openid_consumer).returns( @fake_oid)
          # @fake_oid.stubs(:begin).returns(true)
          # post '/login', :openid_identifier => "foo@gmail.com"
        end

        should "redirect" do
          # flunk
          # assert_equal(302, @response.status)
          # puts response.to_yaml
        end
      end
      
      # redirect since not logged in 
      context "get /login/complete" do
        setup do
          get '/login/complete'
        end
      end
      
      context "get /next" do
        setup do
          
        end

        should "description" do
          
        end
      end
      
      context "post /next" do
        setup do
          
        end

        should "description" do
          
        end
      end
      
      context "get /logout" do
        setup do
          
        end

        should "description" do
          
        end
      end
      
      context "get /bookmarklets" do
        setup do
          
        end

        should "description" do
          
        end
      end
      
      context "get /help" do
        setup do
          
        end

        should "description" do
          
        end
      end
      
      context "get /cancel" do
        setup do
          
        end

        should "description" do
          
        end
      end
      
      context "get /chop" do
        setup do
          
        end

        should "description" do
          
        end
      end

    end
 
  end

end