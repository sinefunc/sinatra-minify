module Sinatra
  module Minify
    module Helpers
      def js_assets(set)
        Package.new(:js, set, self.class).html
      end

      def css_assets(set)
        Package.new(:css, set, self.class).html
      end
    end
  end
end
