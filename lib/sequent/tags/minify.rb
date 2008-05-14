module Sequent
  module Tags
    class Minify < Liquid::Block	
      def render(context)
        output = super.to_s
        STDERR.puts output
        output.gsub(/\n/, '')
      end
 	  end 

 	  Liquid::Template.register_tag('minify', Minify)
  end
end