class CommentObserver < ActiveRecord::Observer
  include Akismet
  
  def after_create(comment)
    # Only check for spam when in production mode...
    if ENV['RAILS_ENV'] == 'production' and !SiteConfig[:akismet_key].nil?
      suspected_spam = is_spam?(
        :comment_type         => 'comment',
        :user_ip              => comment[:ip_address],
        :user_agent           => comment[:user_agent],
        :referrer             => comment[:http_referer],
        :comment_content      => comment[:rendered_body],
        :comment_author       => comment[:author],
        :comment_author_email => comment[:email], 
        :comment_url          => comment[:url]
      )
      comment.update_attribute( 'is_spam', suspected_spam )
      # Send an email to the system admin alerting that there's a new comment
    end
    
  end
  

end
