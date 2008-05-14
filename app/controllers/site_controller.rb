class SiteController < AdminController
   
  def index
  end
  
  def first_run
    @user = current_user
    if request.post?
      if @user.update_attributes(params[:user])
        SiteConfig[:image_sizes]['thumbnail'] = params[:settings].delete( :thumbnail_size )
        params[:settings].keys.each do |key|
          SiteConfig[key] = params[:settings][key]
        end
        Sequent::create_crontab
        SiteConfig[:crontab] = Sequent::has_crontab
        flash[:notice] = "Welcome to sequent!"
        redirect_to admin_home_url()
      end
    end
  end
  
  def save_settings
    pt = SiteConfig[:publish_time]
    SiteConfig[:image_sizes]['thumbnail'] = params[:settings].delete( :thumbnail_size )
    params[:settings].keys.each do |key|
      SiteConfig[key] = params[:settings][key]
    end
    if pt != SiteConfig[:publish_time]
      Sequent::create_crontab 
      SiteConfig[:crontab] = Sequent::has_crontab
      flash[:warning] = "Cron job wasn't successfully created!" unless SiteConfig[:crontab]
    end
    flash[:notice] = "Settings saved"
    redirect_to :back
  rescue ActionController::RedirectBackError
    redirect_to site_url(:action=>'index')
  end
  
  
  def clear_cache
    expire_fragment(/./)
    flash[:notice] = "Server cache cleared"
    redirect_to :back
  rescue ActionController::RedirectBackError
    redirect_to "/admin"
  end

  def publish_overdue
    flash[:notice] = Sequent::publisher
    redirect_to :back
  rescue ActionController::RedirectBackError
    redirect_to "/admin"
  end
  
end