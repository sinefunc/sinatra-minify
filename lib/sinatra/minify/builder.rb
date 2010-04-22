require 'yaml'

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
      def root_path( *args )
        root = File.dirname $0
        root = ROOT_DIR if defined? ROOT_DIR
        File.join(root, *args)
      end

      # Deletes all minified files.
      def clean
        [:js, :css].each do |type|
          assets_config(type).keys.each do |set|
            prefix = type == :js ? settings.js_path : settings.css_path
            path = root_path File.join(prefix, "#{set}.min." + type.to_s)
            File.unlink path if File.exists? path
          end
        end
      end

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
        ::YAML::load(File.open(root_path "config/assets.yml")) [type.to_s]
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
        if settings.minify?
          file = root_path settings.js_path, "#{set}.min.js"
          build unless File.exists? file
          mtime = File.mtime(file).to_i
          "<script src='#{settings.js_url}/#{set}.min.js?#{mtime}' type='text/javascript'></script>\n"
        else
          js_assets_all set
        end
      end

      def js_assets_all( set )
        ret = ''
        assets(:js, set).each do |script|
          ret << "<script src='#{script[:url]}' type='text/javascript'></script>\n"
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
        if settings.minify?
          file = root_path settings.css_path, "#{set}.min.css"
          build unless File.exists? file
          mtime = File.mtime(file).to_i
          "<link rel='stylesheet' href='#{settings.css_url}/#{set}.min.css?#{mtime}' media='screen' />\n"
        else
          css_assets_all set
        end
      end

      def css_assets_all(set)
        assets(:css, set).map { |sheet| "<link rel='stylesheet' href='#{sheet[:url]}' media='screen' />\n" }.join("")
      end

      # Returns the raw consolidated CSS/JS contents of a given type/set
      def combine( type, set )
        assets(type, set).map { |asset| File.open(asset[:path]).read }.join "\n".strip
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
        src.gsub!(/[ \t]*\{[ \t]*/, "{")
        src.gsub!(/;[ \t]*\}/, "}") 

        src.gsub!(/[ \t]*([,|{|}|>|:|;])[ \t]*/,"\\1") # Tersify
        src.gsub!(/[ \t]*\n[ \t]*/, "") # Hardcore mode (no NLs)
        src.strip
      end

      def minify_js( src )
        require 'jsmin'
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
        # type is either :js or :css
        specs = (assets_config type) [set]
        path = get_path type
        done = []
        # `specs` will be a list of filespecs. Find all files that
        # match all specs.
        [specs].flatten.inject([]) do |ret, spec|
          filepath = "#{path}/#{spec}"
          files = Dir[filepath]

          # Add it anyway if it doesn't match anything
          unless files.any? or done.include? filepath or filepath.include?('*')
            ret << { :url => get_url(type, filepath), :path => filepath }
            done << filepath
          end

          files.each do |filename|
            unless done.include? filename
              ret << {
                :url => get_url(type, filename) + "?#{File.mtime(filename).to_i}",
                :path => filename
              }
              done << filename
            end
          end
          ret
        end
      end
    end
  end
end
