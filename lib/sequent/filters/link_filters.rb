module Sequent
  module Filters
    module LinkHelpers
      
      def link_to_post(post, title=nil)
        return nil if post.nil?
        title ||= post['title']
        %Q|<a href="#{url_to_post post}">#{title}</a>|
      end

      def url_to_post(post)
        return nil if post.nil?
        %{#{root_uri}/news/#{post['slug']}}
      end

      def link_to_comic(strip, title=nil, latest_check=false)
        return nil if strip.nil?
        if title.nil? or title.is_a? String
          label = title || (strip['title'] || strip['filename'])
          %Q|<a href="#{url_to_comic strip, latest_check}">#{label}</a>|
        else
          label = strip
          %Q|<a href="#{url_to_comic title, latest_check}">#{label}</a>|
        end
      end

      def url_to_comic(strip, latest_check=false)
        return nil if strip.nil?
        if latest_check and strip['is_last']
          %{#{root_uri}/comic/latest}
        else
          %{#{root_uri}/comic/#{strip['position']}}
        end
      end
      
      def url_to_attachment(filename)
        @context['this']['attachment'][filename]['url']
      end
      
    private
    
      def root_uri
        ActionController::AbstractRequest.relative_url_root || ''
      end
      
    end
    Liquid::Template.register_filter(LinkHelpers)
  end
end
