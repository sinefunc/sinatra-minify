require 'sinatra/base'
require 'yaml'
require 'forwardable'

begin
  require 'jsmin'
rescue LoadError
  require File.join(File.dirname(__FILE__), '..', '..', 'vendor/jsmin-1.0.1/lib/jsmin')
end

module Sinatra
  module Minify
    autoload :Config,     'sinatra/minify/config'
    autoload :Package,    'sinatra/minify/package'
    autoload :Compressor, 'sinatra/minify/compressor'
    autoload :Helpers,    'sinatra/minify/helpers'

    GlobNoMatchError = Class.new(StandardError)
    
    def self.registered( app )
      app.helpers Helpers
      app.set :js_url, '/js' # => http://site.com/js
      app.set :js_path, '/public/js' # => ~/myproject/public/js
      app.set :css_url, '/css'
      app.set :css_path, '/public/css'
      app.set :minify_config, 'config/assets.yml'
      app.disable :force_minify
    end

    def minify?
      production? or force_minify
    end
  end
  register Minify
end
