module Sequent
  module Drops
    class BaseDrop < Liquid::Drop
      class_inheritable_reader :liquid_attributes
      write_inheritable_attribute :liquid_attributes, [:id]
      attr_reader :source
      delegate :hash, :to => :source

      def initialize( src_obj )
        @source = src_obj
        @liquid = liquid_attributes.inject({}) { |h, k| h.update k.to_s => @source.send(k) }
      end

      #def context=(current_context)
      #  super
      #end

      def before_method(method)
        @liquid[method.to_s]
      end

      def eql?(comparison_object)
        self == (comparison_object)
      end

      def ==(comparison_object)
        self.source == (comparison_object.is_a?(self.class) ? comparison_object.source : comparison_object)
      end

      # Pretty much everything that's droppable is commentable, so here we go:
      def comments
        @comments ||= @source.comments.map &:to_liquid
      end
      
      # Used by the comment form tag...
      def is_commentable
        true
      end

      def commentable_id
        @source.id
      end
      
      def commentable_type
        @source.class.to_s
      end

    end
  end
end