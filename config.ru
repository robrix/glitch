require "sinatra"

Sinatra::Application.set :run, :false
Sinatra::Application.set :environment, ENV["RACK_ENV"]

require "glitch"
run Sinatra::Application