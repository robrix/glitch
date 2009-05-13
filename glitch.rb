#!/usr/bin/env ruby -rubygems
require "rubygems"
require "sinatra"

get '/' do
	@repositories = ["."]
	erb :repositories
end

get '/repositories/:name' do |name|
	erb :repository, :locals => {:repository => "/var/repositories/#{name}"}
end