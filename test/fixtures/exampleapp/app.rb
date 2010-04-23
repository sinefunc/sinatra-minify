$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'sinatra/base'
require 'sinatra/minify'

# ROOT_DIR = File.dirname(__FILE__)

class App < Sinatra::Base
  set :app_file, __FILE__

  register Sinatra::Minify
  enable :raise_errors
  get '/' do
    "Hello"
  end

  get "/foo" do
    output = ""
    output << js_assets('base')
  end

  # Doesn't stop Sinatra::Application from running by default
  def self.run?
    false
  end
end

App.run! if $0 == __FILE__
