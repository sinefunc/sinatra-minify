require 'fileutils'
require 'open-uri'

module Sinatra
  module Minify
    class Compressor
      attr :type, :package, :file

      def initialize(type, file, package)
        @type        = type.to_s
        @file        = file
        @package     = package
        @command     = :"minify_#{@type}"
        @host        = ENV["MINIFY_SITE_URL"] || "http://localhost:4567"

        raise ArgumentError  if not ['js', 'css'].include?(type)
      end

      # Rebuilds the minified .min.* files.
      def build
        FileUtils.mkdir_p(File.dirname(file))
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
        package.files.map { |f|
          if File.exist?(f)
            File.read(f)
          else
            path = f.split('public').last
            open("#{ @host }#{ path}").read
          end
        }.join("\n").strip
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
