module Sinatra
  module Minify
    class Builder
      GlobNoMatch = Class.new(StandardError)

      attr :type, :compressor
      
      def self.clean(app_class = ::Main)
        Builder.new(:js, app_class).compressor.clean
        Builder.new(:css, app_class).compressor.clean
      end

      def self.package(app_class = ::Main)
        Builder.new(:js, app_class).compressor.build
        Builder.new(:css, app_class).compressor.build
      end

      def initialize(type, app_class = ::Main)
        @type       = type.to_s
        @app_class  = app_class 
        @compressor = Compressor.new(@type, config.keys, public_dir, self)
      end

      def assets(set)
        if settings.minify?
          file = public_dir(minified_name(set))
          @compressor.build  unless File.exists?(file)
          mtime = File.mtime(file).to_i

          asset_include_tag public_url(minified_name(set)), mtime
        else
          enumerate_all_assets(set)
        end
      end

      def files(set)
        specs = config[set]
        globs = Array(specs).map { |s| public_dir(s) }

        globs.map { |glob| 
          list = Dir[glob]

          if list.empty? and glob.include?('*')
            raise GlobNoMatch, "The spec `#{glob}` does not match any files."
          end

          list.empty? ? glob : list
        }.flatten.uniq
      end

    private
      def enumerate_all_assets(set)
        files(set).map { |file|
          mtime = File.mtime(file).to_i  if File.exist?(file)

          asset_include_tag public_url(file.gsub(/^#{Regexp.escape(public_dir)}/, '')), mtime
        }.join("\n")
      end

      def settings
        @app_class
      end

      # Returns the file sets for a given type as defined in the `assets.yml` config file.
      #
      # Params:
      #  - `type` (Symbol/string) - Can be either `:js` or `:css`
      #
      def config
        YAML.load_file(root_path("config/assets.yml"))[@type]
      end

      # Returns the root path of the main Sinatra application.
      # Mimins the root_path functionality of Monk.`
      def root_path(*args)
        File.join(File.dirname(settings.app_file), *args)
      end
  
      def public_dir(*args)
        root_path(settings.send("#{@type}_path"), *args)
      end

      def public_url(relative_path)
        File.join(settings.send("#{@type}_url"), relative_path).squeeze('/')
      end

      def minified_name(set)
        "#{set}.min.#{type}" 
      end

      def asset_include_tag(relative_path, mtime)
        if @type == 'js'
          "<script src='#{settings.js_url}/#{relative_path}?#{mtime}' type='text/javascript'></script>"
        elsif @type == 'css'
          "<link rel='stylesheet' href='#{settings.css_url}/#{relative_path}?#{mtime}' media='screen' />"
        else
          raise ArgumentError, "only js/css are supported"
        end
      end
    end
  end
end
