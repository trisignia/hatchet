# To use with thin 
#  thin start -p PORT -R config.ru

require File.join(File.dirname(__FILE__), 'hatchet.rb')

disable :run
set :env, :production
run Sinatra.application

#
# Logging (fold)
log = File.new("sinatra.log", "a")
STDOUT.reopen(log)
STDERR.reopen(log)
# (end)
