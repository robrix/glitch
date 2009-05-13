gem "rack", "0.9.1"
require "sinatra"

Sinatra::Application.default_options.merge!(
	:run => false,
	:env => :production
)

require "glitch"
run Sinatra.application