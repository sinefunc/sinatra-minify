module Sinatra
  module Minify
    class Package
      GlobNoMatch = Class.new(StandardError)

      attr :type
      attr :set
      attr :compressor
      attr :filename
  
      def self.all(type, app_class = ::Main)
        config = Config.new(type, app_class)
        config.sets.keys.map do |set|
          Package.new(type, set, app_class)
        end
      end

      def self.clean(app_class = ::Main)
        Package.all(:js, app_class).each  { |p| p.compressor.clean }
        Package.all(:css, app_class).each { |p| p.compressor.clean }
      end

      def self.build(app_class = ::Main)
        ret = []
        ret << Package.all(:js, app_class).map  { |p| p.compressor.build }
        ret << Package.all(:css, app_class).map { |p| p.compressor.build }
        ret.flatten
      end
      
      extend Forwardable
      def_delegators :@config, :public_url, :public_dir, :sets, :js_url, :css_url

      def initialize(type, set, app_class = ::Main)
        @type       = type.to_s
        @app_class  = app_class 
        @set        = set
        @config     = Config.new(@type, app_class)
        @filename   = "#{set}.min.#{type}" 
        @compressor = Compressor.new(@type, public_dir(@filename), self)

      end

      def html
        if @app_class.minify?
          file = public_dir(filename)
          @compressor.build  unless File.exists?(file)
          mtime = File.mtime(file).to_i

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
            raise GlobNoMatch, "The spec `#{glob}` does not match any files."
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
          "<script src='#{js_url}/#{path}?#{mtime}' type='text/javascript'></script>"
        when 'css'
          "<link rel='stylesheet' href='#{css_url}/#{path}?#{mtime}' media='screen' />"
        else
          raise ArgumentError, "only js/css are supported"
        end
      end
    end
  end
end
