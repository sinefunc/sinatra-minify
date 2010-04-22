require 'sinatra/base'
require File.join(File.dirname(__FILE__), 'minify/builder')
require File.join(File.dirname(__FILE__), 'minify/helpers')

module Sinatra
  module Minify
    def self.registered( app )
      app.helpers Helpers
      app.set :js_url, '/js' # => http://site.com/js
      app.set :js_path, '/public/js' # => ~/myproject/public/js
      app.set :css_url, '/css'
      app.set :css_path, '/public/css'
      app.disable :force_minify
    end

    def minify?
      production? or force_minify
    end
  end
  register Minify
end
