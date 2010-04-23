module Sinatra
  module Minify
    class Compressor
      attr :type, :package, :file

      def initialize(type, file, package)
        @type        = type
        @file        = file
        @package     = package
        @command     = :"minify_#{@type}"

        raise ArgumentError  if not ['js', 'css'].include?(type)
      end

      # Rebuilds the minified .min.* files.
      def build
        File.open(file, 'w') { |f| f.write minify(concatenated) }
        file
      end

      # Deletes all minified files.
      def clean
        File.unlink(file)  if File.exists?(file)
      end
  
    private
      # TODO: decouple this further?
      def concatenated
        package.files.map { |f| File.read(f) }.join("\n").strip
      end

      def minify(src)
        send @command, src
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
        JSMin.minify(src).strip
      end
    end
  end
end
