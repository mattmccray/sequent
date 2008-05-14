module Sequent
  module Tags
    class GoogleAd < Liquid::Block	
      def render(context)
        if ENV['RAILS_ENV'] == 'production'
          output = super
          adhtml =<<-EOT
          <script type="text/javascript"><!--
            #{ output.to_s }
          //--></script>
          <script type="text/javascript"
            src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
          </script>
          EOT
        else
          "ADS"
        end
      end
 	  end 

 	  Liquid::Template.register_tag('googlead', GoogleAd)
  end
end