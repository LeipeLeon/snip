require "rubygems"
require "bundler"
require "dotenv/load"

Bundler.require

require "sinatra"
require "newrelic_rpm"
require "./snip"

# log = File.new("log/sinatra.log", "a+")
# $stdout.reopen(log)
# $stderr.reopen(log)

run Sinatra::Application
