class SequentController < ApplicationController
    
  # No layout!!! All the public side will be rendered with Liquid
  layout nil
  
  caches_action :home, :comic, :news, :pages
  cache_sweeper :site_sweeper, :only => [ :add_comment ]
  
  # /          <- Home page
  def home
    ctx = Sequent::Context.init()
    ctx['latest'] = {}
    ctx['latest']['comic'] = Strip.find( :first, :order=>'position DESC', :conditions=>['is_published = ?', true] ).to_liquid
    ctx['latest']['post'] =  Post.find( :first, :order=>'created_on DESC' ).to_liquid
    render_theme_template('home', ctx)
  end
  
  # /comic         <- Archive URL
  # /comic/latest  <- The latest comic URL
  # /comic/15      <- Specific comic URL
  def comic
    ctx = Sequent::Context.init()
    if params[:position].nil?
      ctx['comics'] = Strip.find(:all, :order=>'position', :conditions=>['is_published = ?', true]).map &:to_liquid
      ctx['mode'] = 'list'
    else
      if params[:position] == 'latest'
        ctx['comic'] = Strip.find( :first, :order=>'position DESC', :conditions=>['is_published = ?', true]).to_liquid
      else
        ctx['comic'] = Strip.find_by_position( params[:position] ).to_liquid
      end
      ctx['mode'] = 'single'
    end
    render_theme_template('comic', ctx)
  end
  
  # /news      <- News archive URL
  # /news/slug <- Specific news URL
  def news
    ctx = Sequent::Context.init()
    unless params[:slug].nil?
      ctx['post'] = Post.find_by_slug(params[:slug]).to_liquid
      ctx['mode'] = 'single'
    else
      ctx['posts'] = Post.find(:all, :order=>'created_on DESC').map &:to_liquid
      ctx['mode'] = 'list'
    end
    render_theme_template('news', ctx)
  end
  
  # /page      <- redirects HOME
  # /page/slug <- Specific page URL
  def page
    ctx = Sequent::Context.init()
    redirect_to home_url and return if params[:slug].nil?
    ctx['page'] = Page.find_by_slug(params[:slug]).to_liquid
    render_theme_template('page', ctx)
  end
  
  def add_comment
    cid = params[:comment].delete :commentable_id
    ctype = params[:comment].delete :commentable_type
    obj = ctype.constantize.find(cid)
    # Set some info need for SPAM checking... Damn SPAM
    params[:comment][:ip_address]   = request.remote_ip
    params[:comment][:user_agent]   = request.env['HTTP_USER_AGENT']
    params[:comment][:http_referer] = request.env['HTTP_REFERER']

    obj.comments.create( params[:comment] )
      
    redirect_to :back 
    
  rescue ActionController::RedirectBackError
    redirect_to "/"
  end

end
