module Sequent
  module Tags

    class CommentForm < Liquid::Block	
      Syntax = /(?:with|for)\s+(#{Liquid::QuotedFragment}+)?/

      def initialize(tag_name, markup, tokens)      
        if markup =~ Syntax
          @varname = $1
        else
          raise SyntaxError.new("Error in tag 'commentform' - Valid syntax: commentform for [object]")
        end
        super
      end

      def render(context)
        object = context[@varname]
        site = context['site']
        if object.respond_to?(:is_commentable) and object.is_commentable
          # FIXME: Comment form action and javascript path is hard coded -- need to get the url from a helper...
          output =<<-EOT
          <form method="POST" action="#{ site.urls['comments'] }" onsubmit="return vF(this);">
            <script type="text/javascript" src="/javascripts/form-validation.js"></script>
            <input type="hidden" name="comment[commentable_id]" value="#{ object.commentable_id }"/>
            <input type="hidden" name="comment[commentable_type]" value="#{ object.commentable_type }"/>
            #{ super }
            <script>lF();</script>
          </form>
          EOT
        else
          "Comments not allowed here"
        end
      end
      
 	  end 

    class CommentField < Liquid::Tag
      Syntax = /(#{Liquid::QuotedFragment}+)/

      def initialize(tag_name, markup, tokens)      
        if markup =~ Syntax
          @field = $1.downcase.gsub('"', '').gsub("'", '')
        else
          raise SyntaxError.new("Syntax Error in 'comment_field' - Valid syntax: comment_field [field]")
        end
        super
      end
      
      def render(context)
        case @field
          when 'body'
            %{<textarea class="comment-body" rows="10" cols="50" name="comment[body]" id="comment_body"></textarea>}
          when 'author'
            %Q|<input type="text" class="comment-author" name="comment[author]" id="comment_author"/>|
          when 'email'
            %{<input type="text" class="comment-email" name="comment[email]" id="comment_email" />}
          when 'url'
            %{<input type="text" class="comment-url" name="comment[url]" id="comment_url" />}
          when 'remember'
            %{<input type="checkbox" class="comment-remember" id="comment_remember" />}
        end
      end
    end

 	  Liquid::Template.register_tag('commentform', CommentForm)
 	  Liquid::Template.register_tag('commentfield', CommentField)
  end
end