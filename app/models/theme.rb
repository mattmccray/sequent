class Theme
  cattr_accessor :cache_theme_lookup
  @@cache_theme_lookup = false
  @@root_uri = ActionController::AbstractRequest.relative_url_root || ''
  ASSET_TYPES = %w(images javascripts stylesheets templates)

  attr_accessor :name, :title, :description, :author, :version, :homepage, :summary

  def initialize(name, about={})
    @basepath = Theme.path_for(name)
    @name = name
    @title = about['title'] || name.underscore.humanize.titleize
    @author = about['author'] || 'Unknown'
    @version = about['version'] || '0'
    @homepage = about['homepage'] || ''
    @summary = about['summary'] || @title
  end
  
  def has_preview?
    File.exists?( image_path( 'preview.png' ) ) rescue false
  end
  
  def preview_image
    image_uri( 'preview.png' )
  end

  def asset_uri( type, name )
    # FIXME: the URI creation should be smarter...
    "#{@@root_uri}/themes/#{@name}/#{type}/#{name}"
  end
    
  def asset_path( type, name )
    if ASSET_TYPES.include? type
      File.join(@basepath, type, name)
    else
      throw "Unknown asset type: #{type}"
    end
  end
  
  # Build helper function for each asset type
  ASSET_TYPES.each do |ass| # heheh
    src = <<-END_SRC
      def #{ass.singularize}_path(name)
        asset_path( '#{ass}', name )
      end
      def #{ass.singularize}_uri(name)
        asset_uri( '#{ass}', name )
      end
    END_SRC
    class_eval src, __FILE__, __LINE__
  end

  class << self
    @@themes = nil
    
    def find_all
      installed_themes.inject([]) do |array, path|
        array << new_theme_from_path(path)
      end
    end

    def current
      installed_themes[SiteConfig['theme']]
    end    
    
    def [](name)
      installed_themes[name]
    end
    
    def themes_root
      File.expand_path( File.join(RAILS_ROOT, "themes") )
    end

    def path_for(theme)
      File.join(themes_root, theme)
    end

    def new_theme_from_path(path)
      name = path.scan(/[-\w]+$/i).flatten.first
      self.new(name)
    end

    def installed_themes
      @@themes ||= search_theme_directory
    end  

    def search_theme_directory
      @@themes = {}
      Dir.glob("#{themes_root}/[-_a-zA-Z0-9]*").collect do |path|
        if File.directory?(path) and File.exists?( File.join(path, 'about.yml') )
          name = File.basename(path)
          about = YAML::load( File.open( File.join(path, 'about.yml') ) )
          @@themes[name] = Theme.new(name, about)
        end
      end
      @@themes
    end  
  end

end