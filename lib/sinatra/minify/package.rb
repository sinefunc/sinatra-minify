module Sinatra
  module Minify
    class Package
      attr :type, :set, :compressor, :filename

      class << self
        # Deletes all the different packaged and minified files
        # You may pass in a different application object 
        # e.g.
        #
        #   Sinatra::Minify::Package.clean(HelloWorld)
        #
        # as long as the appication has registered Sinatra::Minify
        # 
        # The files will be based on config/assets.yml
        #
        # See test/fixtures/exampleapp/config/assets.yml for an example
        def clean(app_class = ::Main)
          all(:js, app_class).each  { |p| p.compressor.clean }
          all(:css, app_class).each { |p| p.compressor.clean }
        end
      
        # Packages and minifies all of the files declared on config/assets.yml
        # 
        # Returns all of the minified files
        def build(app_class = ::Main)
          ret = []
          ret << all(:js, app_class).map  { |p| p.compressor.build }
          ret << all(:css, app_class).map { |p| p.compressor.build }
          ret.flatten
        end
        
      private
        def all(type, app_class = ::Main)
          config = Config.new(type, app_class)
          config.sets.keys.map do |set|
            Package.new(type, set, app_class)
          end
        end
      end

      extend Forwardable
      def_delegators :@config, :public_url, :public_dir, :sets, :js_url, :css_url

      def initialize(type, set, app_class = ::Main)
        @type       = type.to_s
        @app_class  = app_class 
        @set        = set.to_s
        @config     = Config.new(@type, app_class)
        @filename   = "#{set}.min.#{type}" 
        @compressor = Compressor.new(@type, public_dir(@filename), self)

      end

      def html
        if @app_class.minify?
          file = public_dir(filename)
          mtime = File.exists?(file) ? File.mtime(file).to_i : ''
          asset_include_tag public_url(filename), mtime
        else
          enumerate_all_assets
        end
      end

      def files
        specs = sets[set]
        globs = Array(specs).map { |s| public_dir(s) }

        globs.map { |glob| 
          list = Dir[glob]

          if list.empty? and glob.include?('*')
            raise GlobNoMatchError, "The spec `#{glob}` does not match any files."
          end

          list.empty? ? glob : list
        }.flatten.uniq
      end

    private
      def enumerate_all_assets
        files.map { |file|
          mtime = File.mtime(file).to_i  if File.exist?(file)

          asset_include_tag(
            public_url(file.gsub(/^#{Regexp.escape(public_dir)}/, '')), mtime
          )
        }.join("\n")
      end

      def asset_include_tag(path, mtime)
        case type
        when 'js'
          "<script src='#{path}?#{mtime}' type='text/javascript'></script>"
        when 'css'
          "<link rel='stylesheet' href='#{path}?#{mtime}' media='all' />"
        else
          raise ArgumentError, "only js/css are supported"
        end
      end
    end
  end
end
