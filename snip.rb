require "dotenv/load"
require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/activerecord"
require "./config/environments"

require "uri"
require "haml"
require "logger"

set :haml, layout: :layout, escape_html: false

configure do
  LOGGER = Logger.new(File.expand_path(File.join(File.dirname(__FILE__), "log", "sinatra.log")))
end

helpers do
  def logger
    LOGGER
  end
end

require "airbrake"

Airbrake.configure do |c|
  c.project_id = ENV.fetch("AIRBRAKE_ID")
  c.project_key = ENV.fetch("AIRBRAKE_KEY")
  # Display debug output.
  # c.logger.level = Logger::DEBUG
end
use Airbrake::Rack::Middleware

class Snip < ActiveRecord::Base
  def self.snip(url)
    uri = URI.parse(url)
    raise "Invalid URL" unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    @snip = Snip.find_or_create_by(original: uri.to_s)
  end

  def self.snap(id, count = true)
    @snip = Snip.find(id.to_i(36))
    @snip.update_attribute(:counter, @snip.counter + 1) if count
    @snip
  end

  def snipped
    id.to_s(36)
  end
end
after do
  ActiveRecord::Base.clear_active_connections!
end

# Overide the logging and print the referer/useragent
module Rack
  class CommonLogger
    FORMAT_COMBINED = %(%s - %s [%s] "%s %s%s %s" %d %s %0.4f "%s" "%s"\n)

    private

    def log(env, status, header, began_at)
      now = Time.now
      length = extract_content_length(header)

      logger = @logger || env["rack.errors"]
      logger.write FORMAT_COMBINED % [
        env["HTTP_X_FORWARDED_FOR"] || env["REMOTE_ADDR"] || "-",
        env["REMOTE_USER"] || "-",
        now.strftime("%d/%b/%Y %H:%M:%S"),
        env["REQUEST_METHOD"],
        env["PATH_INFO"],
        env["QUERY_STRING"].empty? ? "" : "?" + env["QUERY_STRING"],
        env["HTTP_VERSION"],
        status.to_s[0..3],
        length,
        now - began_at,
        env["HTTP_REFERER"],
        env["HTTP_USER_AGENT"]
      ]
    end
  end
end

error ActiveRecord::RecordNotFound do
  haml :index
end
error RuntimeError do
  haml :index
end

get "/" do
  haml :index
end

get "/list" do
  @snips = Snip.limit(50).order("id desc")
  haml :list
end

# get "/api" do
#   @snip = Snip.snip(params[:url])
#   "https://burgr.nl/#{@snip.snipped}"
# end

# post "/" do
#   @snip = Snip.snip(params[:original])
#   haml :index
# end

get "/:snipped" do
  @snip = Snip.snap(params[:snipped])
  redirect @snip.original
end
