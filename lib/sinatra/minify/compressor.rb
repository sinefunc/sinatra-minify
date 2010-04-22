module Sinatra
  module Minify
    class Compressor
      def initialize(type, sets, path_prefix, manifest)
        @type        = type
        @sets        = sets
        @path_prefix = path_prefix
        @manifest    = manifest

        raise ArgumentError  if not ['js', 'css'].include?(@type)
      end

      # Rebuilds the minified .min.* files.
      def build
        @sets.map do |set|
          absolute_path = File.join(@path_prefix, "#{set}.min.#{@type}")
          File.open(absolute_path, 'w') { |f| f.write compress(set) }
          absolute_path
        end
      end

      # Deletes all minified files.
      def clean
        @sets.map do |set|
          absolute_path = File.join(@path_prefix, "#{set}.min.#{@type}")
          File.unlink(absolute_path)  if File.exists?(absolute_path)
        end
      end
  
    private
      def compress(set)
        minify combine(set)
      end
  
      # TODO: decouple this further?
      def combine(set)
        @manifest.files(set).map { |f| File.read(f) }.join("\n").strip
      end

      def minify(src)
        send :"minify_#{@type}", src
      end

      def minify_css(src)
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

      def minify_js(src)
        JSMin.minify src
      end
    end
  end
end
