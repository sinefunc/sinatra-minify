module Sinatra
  module Minify
    module Helpers
      def js_assets( set )
        Builder.new(:js, self.class).assets(set)
      end

      def css_assets( set )
        Builder.new(:css, self.class).assets(set)
      end
    end
  end
end

