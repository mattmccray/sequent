# In charge of caching an Asset, if it's publish_on date is good
class MediaController < ApplicationController
  
  layout nil
  
  
  def fetch
    asset_type = params[:asset_type]
    id = params[:id]
    filename = params[:filename]
    
    # TODO: Fetch asset, and bindata. If the asset is publishable, send it and cache it!
    render :text=>filename
  end
  
  def denied
    render :text=>'DENIED!'
  end
  
end