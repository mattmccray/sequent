class Strip < Asset

  post_processors << :create_thumbnail 

  validates_presence_of :title, :on=>:save, :message=>"must be present"

  acts_as_sluggable :source_column => 'title', :target_column => 'slug' #, :scope => 'type'

  def storyline
    owner
  end
  
  # Override last? to validate against `published_on`
  # def last?
  #   last = super
  #   unless last
  #     last = true if lower_item.published_on > Time.now
  #   end
  #   last
  # end
  
  def to_liquid
    Sequent::Drops::StripDrop.new self
  end

  # x = starting left
  # y = starting top
  # w = width
  # h = height
  def create_preview(x,y,w,h)
    STDERR.puts "CREATING PREVIEW"
    
    # self.meta['versions'] << 'preview'
  end
  
private
  
  def create_thumbnail
    if resize_to('thumbnail', SiteConfig['image_sizes']['thumbnail'] )
      self.meta['versions'] << 'thumbnail'
    end    
  end

end
