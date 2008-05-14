class Avatar < Asset
  post_processors << :create_other_sizes
  
private
  
  def create_other_sizes
    # src_img = MiniMagick::Image.from_file( path_to_file  )
    # src_size = "#{ src_img['width'] }x#{ src_img['height'] }"

    SiteConfig['image_sizes']['avatars'].each do |size|
      resize_to(size, size) # TODO: Do we need to make sure the size isn't the source size?
      self.meta['versions'] << size
    end
    
  rescue
    STDERR.puts "Error creating other sizes: #{$!}"
  end

end