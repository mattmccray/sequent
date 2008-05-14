class Wallpaper < Asset

  post_processors << :create_thumbnail << :create_other_sizes

private

  def create_thumbnail
    if resize_to('thumbnail', SiteConfig['image_sizes']['thumbnail'] )
      self.meta['versions'] << 'thumbnail'
    end    
  end  

  def create_other_sizes
    src_img = MiniMagick::Image.from_file( path_to_file  )
    src_ratio = get_ratio(src_img['width'], src_img['height'])

    SiteConfig['image_sizes']['screens'][src_ratio].each do |size|
      resize_to(size, size) # TODO: Do we need to make sure the size isn't the source size?
      self.meta['versions'] << size
    end

  rescue
    STDERR.puts "Error creating other sizes: #{$!}"
  end
  
  def get_ratio( width, height )
    if width.to_f / height.to_f < 1.34
      'standard' # Standard is actually 1.33
    else
      'wide'
    end
  end

end