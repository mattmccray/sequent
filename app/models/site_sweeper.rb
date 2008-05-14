class SiteSweeper < ActionController::Caching::Sweeper
  observe Page, Post, Strip, Content, Asset, Comment

  def after_save(record)
    ctype = record.type.to_s
    STDERR.puts "SWEEPING FOR: #{ctype}"
    if ctype == 'Comment'
      expire_based_on_type( record.commentable, record.commentable_type )
    else
      expire_based_on_type( record, ctype )
    end
  end

  def expire_based_on_type(obj, ctype)
    case ctype
      when 'Strip'
        # Clear entire comic cache...
        Strip.count.times do |i|
          expire_action( comic_url(:position=>(i-1)) )
        end
        expire_action( comic_url(:position=>'latest') )
        expire_action( comic_url(nil) )
        expire_action( home_url() )
      when 'Post'
        expire_action( news_url(:slug=>obj.slug) )
        expire_action( news_url(nil) )
        expire_action( home_url() )
      when 'Page'
        expire_action( page_url(:slug=>obj.slug) )
    end    
  end
  
end

