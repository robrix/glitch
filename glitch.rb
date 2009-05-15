#!/usr/bin/env ruby -rubygems
require "rubygems"
require "sinatra"
require "grit"

helpers do
	include Rack::Utils
	
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
	
	def quantity(n, noun, plural_noun = nil)
		n.to_s + " " + if n == 1
			noun
		else
			plural_noun || "#{noun}s"
		end
	end

	def relative_time(time)
		seconds = (Time.now - time).to_i
		minutes = (seconds / 60).round
		hours = (minutes / 60).round
		days = (hours / 24).round
		months = (days / 30).round
		years = (months / 12).round
		
		if years == 0
			if months == 0
				if days == 0
					if hours == 0
						if minutes == 0
							if seconds == 0
								"now! How did you do that?"
							else
								"#{quantity(seconds, "second")} ago"
							end
						else
							"about #{quantity(minutes, "minute")} ago"
						end
					else
						"about #{quantity(hours, "hour")} ago"
					end
				else
					"about #{quantity(days, "day")} ago"
				end
			else
				"about #{quantity(months, "month")} ago"
			end
		else
			"about #{quantity(years, "year")} ago"
		end
	end
end

before do
	headers "Content-Type" => if request.path_info =~ /\.xml$/
		"application/atom+xml"
	else
		"text/html; charset=utf-8"
	end
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