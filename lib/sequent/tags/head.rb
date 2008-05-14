module Sequent
  module Tags
    class Head < Liquid::Block	
      def render(context)
        # <script src="/javascripts/site.js" type="text/javascript"></script>
        output =<<-EOT
        <head>
          #{ super }
          <link rel="alternate" type="application/rss+xml" title="RSS Feed" href="/feed/all" />
        </head>
        EOT
      end
 	  end 

 	  Liquid::Template.register_tag('head', Head)
  end
end