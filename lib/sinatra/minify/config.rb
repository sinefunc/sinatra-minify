module Sinatra
  module Minify
    class Config
      def initialize(type, app_class = ::Main)
        @settings = app_class   
        @type     = type.to_s
      end

      def js_url
        @settings.js_url
      end

      def css_url
        @settings.css_url
      end

      def public_dir(*args)
        root_path(@settings.send("#{@type}_path"), *args)
      end

      def public_url(path)
        File.join(@settings.send("#{@type}_url"), path).squeeze('/')
      end

      def root_path(*args)
        File.join(File.dirname(@settings.app_file), *args)
      end

      def config_file
        @settings.minify_config
      end

      def sets
        YAML.load_file(root_path(config_file))[@type]
      end
    end
  end
end
