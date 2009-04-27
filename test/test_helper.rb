%w(rubygems sinatra sinatra/test/unit shoulda mocha).each{|lib| require lib}
require File.join(File.dirname(__FILE__), '..', 'hatchet')

set :views,  '../views'