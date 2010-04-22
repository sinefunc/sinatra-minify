$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'sinatra'
require 'sinatra/minify'

ROOT_DIR = File.dirname(__FILE__)

class App < Sinatra::Base
  register Sinatra::Minify

  get '/' do
    "Hello"
  end

  get "/foo" do
    output = ""
    output << js_assets('base')
  end
end
