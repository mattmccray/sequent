module Sequent
  module Drops
    class AssetDrop < BaseDrop
      liquid_attributes << :title << :slug << :published_on << :filename 
      liquid_attributes << :mimetype<< :created_on << :updated_on << :position
      
      def initialize(source)
         super source 
         @liquid.update 'thumbnail_url' => @source.url_to_file('thumbnail')
      end

      def first
        @source.class.find(:first, :order=>'position ASC').to_liquid
      end
      
      def previous
        @source.higher_item.to_liquid unless is_first
      end

      def next
        @source.lower_item.to_liquid unless is_last
      end

      def last
       @last ||= get_latest.to_liquid
      end

      def is_first
        @source.first?
      end

      def is_last
        @source == get_latest
      end

      def url
        @source.url_to_file
      end
      
      def versions 
        @versions ||= @source.meta['versions'].map do |version|
          { 'size'=>version, 'url'=>@source.url_to_file(version) }
        end
      end

      def version
        @version ||= begin
          @version = {}
          versions.map do |version|
            @version[version['size']] = version['url']
          end
          @version
        end
      end
      
      # For Wallpapers and Avatars, mostly...
      def sizes 
        @sizes ||= versions.reject {|v| v['size'] == 'thumbnail' }
      end
      
      def notes
        @source.notes_rendered
      end
      
      def body
        notes
      end

    private

      def get_latest
         @source.class.find(:first, :order=>'position DESC', :conditions=>['is_published = ?', true])
      end
      
    end
  end
end