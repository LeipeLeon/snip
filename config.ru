require "rubygems"
require "bundler"

Bundler.require

require "sinatra"
require "newrelic_rpm"
require "./snip"

# log = File.new("log/sinatra.log", "a+")
# $stdout.reopen(log)
# $stderr.reopen(log)

run Sinatra::Application
