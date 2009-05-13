#!/usr/bin/env ruby -rubygems
require "rubygems"
require "sinatra"
require "grit"

helpers do
	def repo_root
		ENV["GLITCH_REPO_ROOT"] || "/var/repositories"
	end
	
	def repos
		ENV["GLITCH_REPOS"] || "*"
	end
end

get '/' do
	@repositories = repos.collect do |repo|
		Dir.glob("#{repo_root}/#{repo}").select do |dir|
			dir[/.git$/] or File.exists?("#{dir}/.git")
		end
	end.flatten
	erb :repositories
end

get '/repos/:name' do |name|
	erb :repository, :locals => {:repository => Grit::Repo.new("#{repo_root}/#{name}")}
end