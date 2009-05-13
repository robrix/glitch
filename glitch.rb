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

before do
	headers "Content-Type" => "text/html; charset=utf-8"
end

module Grit
	class Repo
		def name
			@name ||= File.basename((File.basename(self.path) == ".git") ? self.working_dir : self.path)
		end
	end
end

get %r{/(repos)?$} do
	erb :repositories
end

get '/repos/:name/?$' do |name|
	halt 404, "No such repository" unless is_valid_repo?(name)
	erb :repository, :locals => {:repository => Grit::Repo.new("#{repo_root}/#{name}")}
end

get '/repos/:name/branches/:branch/?$' do |name, branch|
	halt 404, "No such repository" unless is_valid_repo?(name)
	@repository = Grit::Repo.new("#{repo_root}/#{name}")
	@branch = @repository.get_head(branch)
	halt 404, "No such branch" unless @branch
	erb :branch
end

get '/repos/:name/commits/:hash' do |name, hash|
	halt 404, "No such repository" unless is_valid_repo?(name)
	@repository = Grit::Repo.new("#{repo_root}/#{name}")
	@commit = @repository.commit(hash)
	halt 404, "No such commit" unless @commit
	erb :commit
end