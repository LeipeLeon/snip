require 'rubygems'
require 'sinatra'
require 'snip.rb'

log = File.new("log/sinatra.log", "a+")
$stdout.reopen(log)
$stderr.reopen(log)

run Sinatra::Application
