require 'test_helper'

class HatchetTest < Test::Unit::TestCase

  context "Hatchet" do
    
    context "get /" do
      setup do
        get '/'
      end
      
      should "respond" do
        assert @response.body
      end
    end
    

    context "get /signup" do
      setup do
        get '/signup'
      end
      
      should "respond" do
        assert @response.body
      end
    end
    

    context "post /signup" do
      setup do
        post '/signup'
      end
      
      should "respond" do
        assert @response.body
      end
    end
    

    context "get /thanks" do
      setup do
        get '/thanks'
      end
      
      should "respond" do
        assert @response.body
      end
    end
    
  end

end