module Sinatra
  module Minify
    module Helpers
      def js_assets( set )
        Builder.new(self.class).js_assets set
      end

      def css_assets( set )
        Builder.new(self.class).css_assets set
      end
    end
  end
end

