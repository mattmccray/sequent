module Sequent
  module Drops
    class ContentDrop < BaseDrop
      liquid_attributes << :title << :slug << :created_on << :updated_on

      def initialize(source)
         super source
         #@liquid.update 'body' => @source.body_rendered
      end
      
      def attachments
        @source.attachments.map &:to_liquid
      end
      
      def attachment
        @attachments ||= begin
          @attachments = {}
          attachments.each do |att|
            @attachments[att['filename']] = att
          end
          @attachments
        end
      end
      
      def body
        @source.body_rendered
      end
            
    end
  end
end