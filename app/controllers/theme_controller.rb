class ThemeController < ApplicationController

  after_filter :cache_theme_files

  def stylesheets
    render_theme_item(:stylesheets, params[:filename].to_s, params[:theme], 'text/css')
  end

  def javascripts
    render_theme_item(:javascripts, params[:filename].to_s, params[:theme], 'text/javascript')
  end

  def images
    render_theme_item(:images, params[:filename].to_s, params[:theme])
  end

  def error
    render :nothing => true, :status => 404
  end

private

  def render_theme_item(type, file, theme, mime = mime_for(file))
    asset_path = Theme[theme].asset_path(type.to_s, file)
    render :text => "Not Found", :status => 404 and return if file.split(%r{[\\/]}).include?("..") or !File.exists?(asset_path)
    send_file( asset_path, :type => mime, :disposition => 'inline', :stream => false )
  end

  def cache_theme_files
    path = request.request_uri
    #Fixme: We don't want this for 404's
    begin
      ThemeController.cache_page( response.body, path )
    rescue
      logger.info "Cache Exception: #{$!}"
    end
  end


  def mime_for(filename)
    case filename.downcase
      when /\.js$/
        'text/javascript'
      when /\.css$/
        'text/css'
      when /\.gif$/
        'image/gif'
      when /(\.jpg|\.jpeg)$/
        'image/jpeg'
      when /\.png$/
        'image/png'
      when /\.swf$/
        'application/x-shockwave-flash'
    else
        'application/binary'
    end
  end

end