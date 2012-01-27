%w(rubygems sinatra active_record uri haml logger).each  { |lib| require lib}

ActiveRecord::Base.establish_connection(
  YAML.load_file(File.expand_path(File.join(File.dirname(__FILE__), 'config', 'database.yml')))
)

configure do
  LOGGER = Logger.new(File.expand_path(File.join(File.dirname(__FILE__), 'log', 'sinatra.log')))
end
 
helpers do
  def logger
    LOGGER
  end
end

class Snip < ActiveRecord::Base
  def self.snip(url)
    uri = URI::parse(url)
    raise "Invalid URL" unless uri.kind_of? URI::HTTP or uri.kind_of? URI::HTTPS
    @snip = Snip.find_or_create_by_original(uri.to_s)
  end
  def self.snap(id, count = true)
    @snip = Snip.find(id.to_i(36))
    @snip.update_attribute(:counter, @snip.counter + 1) if count
    @snip
  end
  def snipped
    self.id.to_s(36)
  end
end

error ActiveRecord::RecordNotFound do
  haml :index
end

get '/' do haml :index end

get '/list' do 
  @snips = Snip.find(:all, :limit => 50, :order => "id desc")
  haml :list
end

get '/api' do
  @snip = Snip.snip(params[:url])
  "http://burgr.nl/#{@snip.snipped}"
end

post '/' do
  @snip = Snip.snip(params[:original])
  haml :index
end

get '/:snipped' do 
  @snip = Snip.snap(params[:snipped])
  redirect @snip.original
end
