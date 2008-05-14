class FeedController < ApplicationController

  # No layout, 'cause it's all RSS!
  layout nil

  def all
    # Merge last 10 comics and news posts by publish/create date and
    # return RSS for top 10 of those...
    comics
    news
    @all = comics + news
    @all.sort! do |a,b| 
      a.published_on.to_f <=> b.published_on.to_f
    end.reverse!
    @all = @all[0..10]
  end

  def comics
    # 10 latest comic strip including preview/thumbnail
    @strips = Strip.find( :all, :limit=>10, :order=>'published_on ASC', :conditions=>['published_on <= ?', Time.now] )
  end

  def news
    # 10 latest news posts
    @posts = Post.find( :all, :limit=>10, :order=>'created_on ASC' )
  end
end
