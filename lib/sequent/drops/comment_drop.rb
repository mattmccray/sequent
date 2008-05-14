module Sequent
  module Drops
    class CommentDrop < BaseDrop
      liquid_attributes << :created_on << :updated_on << :author << :url << :email

      def initialize(source)
         super source
         #@liquid.update 'body' => @source.body_rendered
         # FIXME: If the comment has an author_id, populate the author, url, email based on that and set a 'is_creator' flag
      end
      
      def is_commentable
        false
      end
      
      def body
        @source.body_rendered
      end
      
    end
  end
end