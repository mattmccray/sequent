class AdminController < ApplicationController

  before_filter :login_required
  before_filter :first_run_check, :except=>[:first_run]

  def index
    render :text=>'How did you get here?'
  end

private

  def first_run_check
    if SiteConfig[:first_run]
      redirect_to site_url( :action=>'first_run' )
    end
  end
  

end
