#!/usr/bin/env ruby -rubygems
require "rubygems"
require "sinatra"
require "grit"

helpers do
	def repo_root
		ENV["GLITCH_REPO_ROOT"] || "/var/repositories"
	end
	
	def repos
		ENV["GLITCH_REPOS"] ? ENV["GLITCH_REPOS"].split(":") || ["*"]
	end
	
	@repositories = repos.collect do |repo|
		Dir.glob("#{repo_root}/#{repo}").select do |dir|
			dir[/.git$/] or File.exists?("#{dir}/.git")
		end
	end.flatten
end

get '/' do
	erb :repositories
end

get '/repos/:name' do |name|
	erb :repository, :locals => {:repository => Grit::Repo.new("#{repo_root}/#{name}")}
end

get '/debug' do
	erb @repositories.join("<br>\n")
end