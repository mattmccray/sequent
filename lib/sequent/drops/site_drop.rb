module Sequent
  module Drops
    class SiteDrop < Liquid::Drop
      attr_reader :controller
      
      def comics
        Strip.find(:all, :order=>'position', :conditions=>['is_published = ?', true]).map &:to_liquid
      end
      
      def strips
        comics
      end
      
      def posts
        Post.find(:all).map &:to_liquid
      end
      
      def news
        posts
      end
      
      def pages
        Page.find(:all).map &:to_liquid
      end
      
      def wallpapers
        Wallpaper.find(:all).map &:to_liquid
      end

      def avatars
        Avatar.find(:all).map &:to_liquid
      end
      
      def is_commentable
        false
      end
      
      def urls
        # FIXME: These URL's need to be dynamically generated... Somehow
        {
          'comments' => '/add_comment',
          'admin'    => '/admin'
        }
      end
      
      def title
        SiteConfig[:title]
      end

      def authors
        SiteConfig[:authors]
      end

      def description
        SiteConfig[:description]
      end
      
    end
  end
end