module Sinatra
  module Minify
    class Builder
      GlobNoMatch = Class.new(StandardError)

      attr :type
      
      def self.clean
      end

      def self.package
      end

      def initialize(type, app_class = ::Main)
        @type       = type.to_s
        @app_class  = app_class 
      end

      def assets(set)
        if settings.minify?
          file = public_dir(minified_name(set))
          build  unless File.exists?(file)
          mtime = File.mtime(file).to_i

          asset_include_tag public_url(minified_name(set)), mtime
        else
          enumerate_all_assets(set)
        end
      end

    private
      def enumerate_all_assets(set)
        specs = config[set]
        globs = Array(specs).map { |s| public_dir(s) }

        files = globs.map { |glob| 
          list = Dir[glob]

          if list.empty? and glob.include?('*')
            raise GlobNoMatch, "The spec `#{glob}` does not match any files."
          end

          list.empty? ? glob : list
        }.flatten.uniq

        files.map { |file|
          mtime = File.mtime(file).to_i  if File.exist?(file)

          asset_include_tag public_url(file.tr(public_dir, '')), mtime
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
        File.join(settings.send("#{@type}_url"), relative_path)
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
