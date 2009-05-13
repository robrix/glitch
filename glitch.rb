#!/usr/bin/env ruby -rubygems
require "rubygems"
require "sinatra"

REPOSITORIES_ROOT = "/var/repositories"
REPOSITORIES = ["*"]

get '/' do
	@repositories = REPOSITORIES.collect{ |repo| Dir.glob("#{REPOSITORIES_ROOT}/#{repo}") }.flatten
	erb :repositories
end

get '/repositories/:name' do |name|
	erb :repository, :locals => {:repository => Grit::Repo.new("#{REPOSITORIES_ROOT}/#{name}")}
end