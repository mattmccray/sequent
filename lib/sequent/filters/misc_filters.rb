require 'digest/md5'
require 'cgi'

module Sequent
  module Filters
    module MiscHelpers
            
      def gravatar_url( email, size=50, rating='PG' )
        email_hash = Digest::MD5.hexdigest( email )
        default_img = CGI::escape( "#{root_uri}#{Theme.current.image_uri('default_gravatar.png')}" )
         "http://www.gravatar.com/avatar.php?gravatar_id=#{email_hash}&size=#{size}&rating=#{rating}&default=#{default_img}"
      end

      def pluralize(size, statement="item")
        "#{ size } #{(size.to_i == 1) ? statement : statement.pluralize }"
      end

    private

      def root_uri
        ActionController::AbstractRequest.relative_url_root || ''
      end
      
    end

    Liquid::Template.register_filter(MiscHelpers)

  end
end
