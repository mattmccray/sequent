module Sequent
  module Filters
    module ThemeHelpers
      
      def stylesheet_path( name )
        Theme.current.stylesheet_uri name
      end
      
      def javascript_path( name )
        Theme.current.javascript_uri name
      end
      
      def image_path( name )
        Theme.current.image_uri name
      end
      
    end
    Liquid::Template.register_filter(ThemeHelpers)
  end
end
