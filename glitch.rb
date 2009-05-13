#!/usr/bin/env ruby -rubygems
require "rubygems"
require "sinatra"
require "grit"

helpers do
	def repo_root
		@repo_root ||= ENV["GLITCH_REPO_ROOT"] || "/var/repositories"
	end
	
	def repo_names
		@repo_names ||= ENV["GLITCH_REPOS"] ? ENV["GLITCH_REPOS"].split(":") : ["*"]
	end
	
	def repos
		@repositories ||= repo_names.collect do |repo|
			Dir.glob("#{repo_root}/#{repo}").select do |dir|
				dir[/.git$/] or File.exists?("#{dir}/.git")
			end
		end.flatten
	end
	
	def is_valid_repo?(name)
		repo_names.include?("*") || repo_names.include?(name)
	end
end

get %r{/(repos)?$} do
	erb :repositories
end

get '/repos/:name' do |name|
	halt 403, "Forbidden" unless is_valid_repo?(name)
	erb :repository, :locals => {:repository => Grit::Repo.new("#{repo_root}/#{name}")}
end