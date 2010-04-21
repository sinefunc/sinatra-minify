require 'jsmin'

module Sinatra
  module Minify
    module Helpers
      def js_assets( set )
        Builder.new(self.class).js_assets set
      end
      def css_assets( set )
        Builder.new(self.class).css_assets set
      end
    end

    class Builder
      def build
        out = []
        [:js, :css].each do |type|
          assets_config(type).keys.each do |set|
            prefix = type == :js ? settings.js_path : settings.css_path
            path = root_path File.join(prefix, "#{set}.min." + type.to_s)
            File.open(path, 'w') << compress(type, set)
            out << path
          end
        end
        out
      end

      def initialize( app_class = ::Main )
        @app_class = app_class
      end

      def settings
        @app_class
      end

      # Returns the file sets for a given type as defined in the `assets.yml` config file.
      #
      # Params:
      #  - `type` (Symbol/string) - Can be either `:javascripts` or `:stylesheets`
      #
      def assets_config(type)
        YAML::load(File.open(root_path "config/assets.yml")) [type.to_s]
      end

      # Returns HTML code with `<script>` tags to include the scripts in a given `set`.
      #
      # Params:
      #   - `set` (String) - The set name, as defined in `config/assets.yml`.
      #
      # Example:
      #
      #   <%= js_assets 'base' %>
      #
      def js_assets( set )
        if settings.production?
          "<script src='#{settings.js_url}/#{set}.min.js' type='text/javascript'></script>\n"
        else
          js_assets_all set
        end
      end

      def js_assets_all( set )
        ret = ''
        assets(:js, set).each do |script|
          ret << "<script src=\"#{script[:url]}\" type=\"text/javascript\"></script>\n"
        end
        ret
      end

      # Returns HTML code with `<link>` tags to include the stylesheets in a given `set`.
      #
      # Params:
      #   - `set` (String) - The set name, as defined in `config/assets.yml`.
      #
      # Example:
      #
      #   <%= css_assets 'base' %>
      #
      def css_assets( set )
        if settings.production? 
          "<link rel='stylesheet' href='#{settings.css_url}/#{set}.min.css' media='screen' />\n"
        else
          css_assets_all set
        end
      end

      def css_assets_all(set)
        ret = ''
        (assets_config :css) [set].each do |filename|
          ret << "<link rel='stylesheet' href='#{settings.css_url}/#{filename}' media='screen' />\n"
        end
        ret
      end

      # Returns the raw consolidated CSS/JS contents of a given type/set
      def combine( type, set )
        assets(type, set).map { |asset| File.open(asset[:path]).read }.join "\n"
      end

      # Returns compressed code
      def compress( type, set )
        code = combine type, set
        if type == :js
          minify_js code
        elsif type == :css
          minify_css code
        else
          raise Exception.new
        end
      end

      def minify_css( src )
        src.gsub!(/\s+/, " ")         
        src.gsub!(/\/\*(.*?)\*\//, "")
        src.gsub!(/\} /, "}\n")       
        src.gsub!(/\n$/, "")          
        src.gsub!(/ \{ /, " {")       
        src.gsub!(/; \}/, "}") 
        src
      end

      def minify_js( src )
        JSMin.minify src
      end


      # Returns the file path of where assets of a certain type are stored.
      #
      # Params:
      #   - `type` (Symbol)  - Either `:js` or `:css`.
      #
      # Example:
      #   get_path :js
      #   # Possible value: "/home/rsc/myproject/public/js" 
      #
      def get_path( type )
        if type == :js
          path = settings.js_path 
        else
          path = settings.css_path
        end
        root_path(path.split('/').inject([]) { |arr, item| arr << item unless item.empty?; arr })
      end

      # Returns the URL for a given filename and a type.
      #
      # Params:
      #   - `type` (Symbol)  - Either `:js` or `:css`.
      #
      # Example:
      #   get_url :js, '/path/to/file.js'
      #
      def get_url( type, filename )
        if type == :js
          prefix = settings.js_url
        else
          prefix = settings.css_url
        end
        # Remove the js_path from it (/home/rsc/project/public/js/aa/lol.js => aa/lol.js)
        url = File.join(prefix, filename.split(get_path type).join(''))

        # Remove duplicate slashes
        url = url.split('/').inject([]) { |arr, item| arr << item unless item.empty?; arr }
        '/' + url.join('/')
      end

      # Returns a list of assets of a given type for a given set.
      #
      # Params:
      #   - `type` (Symbol)  - Either `:js` or `:css`.
      #   - `set` (String)   - The set name, as defined in `config/assets.yml`.
      #
      # Returns:
      #   An array of objects.
      #
      #  Example:
      #
      #     puts assets(:js, 'base').to_json
      #     # Possible output:
      #     # [ { 'url': '/js/app.js', 'path': '/home/rsc/projects/assets/public/js/app.js' },
      #     #   { 'url': '/js/main.js', 'path': '/home/rsc/projects/assets/public/js/main.js' },
      #     #   ...
      #     # ]
      #
      # See also:
      #   - js_assets
      #
      def assets( type, set )
        # type is either js or css
        specs = (assets_config type) [set]
        path = get_path type
        ret = []
        done = []
        # `specs` will be a list of filespecs. Find all files that
        # match all specs.
        if specs.class == Array
          specs.each do |spec|
            Dir["#{path}/#{spec}"].each do |filename|
              unless done.include? filename
                ret << {
                  :url => get_url(type, filename),
                  :path => filename
                }
                done << filename
              end
            end
          end
        end
        ret
      end
    end
  end
end
