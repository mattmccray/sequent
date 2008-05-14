# :assetowner_id, :integer
# :assetowner_type, :string
# :title, :string # optional -- for strip type
# :slug, :string  # optional -- for strip type
# :filename, :string
# :mimetype, :string
# :notes, :text
# :rendered_notes, :text
# :published_on, :datetime
# :position, :integer, :default=>0
# :type, :string
# :created_on, :datetime
# :updated_on, :datetime

# Base class for all the asset types:
#
#  Attachment, Avatar, Strip, Wallpaper
#
# Filesystem: RAILS_ROOT/public/assets/:type/:id/*
class Asset < ActiveRecord::Base
  
  class_inheritable_reader :post_processors
  write_inheritable_attribute :post_processors, []
  
  has_many :comments, :as=>:commentable, :dependent=>:destroy, :conditions=>['is_spam = ?', false]
  belongs_to :assetowner, :polymorphic=>true
  # Each type of asset is a list -- mainly for 'comic'
  acts_as_list :scope=>%q{type = '#{type}'}

  rendered_column :notes do |asset, ctx|
    ctx['this'] = asset.to_liquid
  end
  
  serialize :meta, Hash

  before_save :set_publishing_info

  def uploadedfile=( filedata )
    @uploaded_file = filedata
    self.filename  = sanitize_filename(@uploaded_file.original_filename)
    self.mimetype  = @uploaded_file.content_type
    self.meta = { 'versions'=>[] }
  end
  
  def after_create
    update_attribute('title', self[:filename]) if self[:title].nil? or self[:title].to_s.empty?

    file_path = self.path_to_file
    file_dir = File.dirname(file_path)

    File.umask 0000 
    begin
      FileUtils.mkdir_p( file_dir, :mode=>0777 )
    rescue
      STDERR.puts "Couldn't mkdir_p #{file_dir}: #{$!}"
    end if !File.exists? file_dir

    if @uploaded_file.instance_of? Tempfile
      FileUtils.copy(@uploaded_file.local_path, file_path)
    else
      File.open(file_path, "wb") { |f| f.write(@uploaded_file.read) }
    end
    File.chmod(0777, file_path)
    
    do_post_processing
  end

  def before_destroy
    @versions_to_cleanup = self.meta['versions'].clone
  end

  def after_destroy

    @versions_to_cleanup.each do |size|
      if File.exists? path_to_file(size)
        File.delete path_to_file(size)
      end
    end

    if File.exists? path_to_file
      File.delete path_to_file
    end
    # Should be empty... Could just force it and be done, eh?
    FileUtils.remove_dir(File.dirname(path_to_file), true)
  end
  
  def url_to_file( version='default' )
    version = 'default' if version=='thumbnail' and !self.meta['versions'].include? 'thumbnail' 
    get_urlpath_for( version )
  end

  def path_to_file( version='default' )
    get_filepath_for( version )
  end
    
  def owner
    unless assetowner_id.nil?
      @owner ||= assetowner_type.constantize.find(assetowner_id)
    end
  end
  
  def owner_type
    assetowner_type
  end
  
  def to_liquid
    Sequent::Drops::AssetDrop.new self
  end
  
  def publish_files
    pending_file_dir = pending_file_path
    public_file_dir = public_file_path
STDERR.puts "************************************"
    STDERR.puts "pending_file_dir = #{pending_file_dir}"
    STDERR.puts "public_file_dir = #{public_file_dir}"
    
    if self.is_published and FileTest.directory?( pending_file_dir )
      STDERR.puts "Move from PENDING to PUBLIC"
      FileUtils.mv( pending_file_dir, public_file_dir, :force=>true )
    elsif !self.is_published and FileTest.directory?( public_file_dir )
      STDERR.puts "Move from PUBLIC to PENDING"
      FileUtils.mv( public_file_dir, pending_file_dir, :force=>true )
    end
  end  
    
private

  def set_publishing_info
    # Set a published_on date, if it's nil
    if self.published_on.nil?
      self.published_on = Time.today
    end
    self.is_published = (Time.now >= self.published_on)
    true # Done... Move along
  end

  def do_post_processing
    post_processors.each do |proc|
      send(proc)
    end
    # the processors may add things to the meta hash, so save any changes
    self.save
  end

  def resize_to(name, img_size)
    img = MiniMagick::Image.from_file( path_to_file  )
    img.resize( img_size ) 
    img.write( get_filepath_for(name) )
    true
  rescue
    # Error creating thumbnail! 
    STDERR.puts "Error resizing image: #{$!}"
    false
  end
  
  def get_filename_for(version='default')
    if version == 'default'
      self.filename
    else
      self.filename.split('.').insert(-2, version).join('.')
    end
  end
  
  def get_filepath_for(version='default')
    "#{root_file_path}/#{ get_filename_for(version) }"
  end  
  
  def get_urlpath_for(version='default')
    "#{root_web_path}/#{ get_filename_for(version) }"
  end
  
  def root_file_path(mode=:auto)
    File.expand_path File.join(RAILS_ROOT, 'public', 'media', filetype_dir(mode), self.id.to_s)
  end

  def pending_file_path
    root_file_path(:pending)
  end

  def public_file_path
    root_file_path(:public)
  end

  def root_web_path
    "/media/#{filetype_dir}/#{self.id}"
  end
  
  def filetype_dir(mode=:auto)
    case mode
    when :public
      self.type.to_s.downcase
    when :pending
      '.pending'            
    else
      if self.is_published
        self.type.to_s.downcase
      else
        '.pending'
      end
    end
  end

  # Makes files 'safe', also fixes weird issue with IE posted filenames...
  def sanitize_filename(value)
      # get only the filename, not the whole path
      just_filename = value.gsub(/^.*(\\|\/)/, '')
      # Finally, replace all non alphanumeric, underscore or periods with underscore
      just_filename.gsub(/[^\w\.\-]/,'_') 
  end

  def get_file_extension(file_name)
    file_name.split('.')[-1] || ''
  end
    
end
