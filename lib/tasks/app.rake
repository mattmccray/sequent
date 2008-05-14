namespace :app do
  desc "Initialize the Sequent Database"
  task :setup =>['db:schema:load'] do

    # Create the file upload folders
    File.umask(0000)
    ['avatar', 'attachment', 'wallpaper', 'strip', '.pending'].each do |asset_type|
      FileUtils.mkdir_p "#{RAILS_ROOT}/public/media/#{asset_type}"
      File.chmod(0777, "#{RAILS_ROOT}/public/media/#{asset_type}")
    end
    File.open("#{RAILS_ROOT}/public/media/.pending/.htaccess", 'w') do |f|
      f.write <<-EOF 
deny from all
      EOF
    end

    # Create default admin user...
    puts "Creating admin user..."
    User.create \
      :login=>'admin', 
      :password=>'test', 
      :password_confirmation=>'test', 
      :email=>'admin@thisdomain.com',
      :display_name=>'Da Man'
    
    puts ""
    puts "You can login to sequent with:"
    puts "  username: admin"
    puts "  password: test   (be sure and change the password right away!)"
    puts ""

    puts "Creating initial pages and settings... "
    # Initial pages
    %w(links store about extra contact).each do |title|
      Page.create :title=>title.capitalize, :body=>'Content goes here...'
    end
    
    # First news post
    Post.create :title=>'Site Setup Successful!', :body=>'Your setup is ready to go... You might wanna update the theme, though.'
    
    # Initial Site Configurations
    SiteConfig[:first_run] = true
    SiteConfig[:title] = "My Webcomic"
    SiteConfig[:description] = "The most l33t web-comic evar!"
    SiteConfig[:authors] = "Me"
    SiteConfig[:akismet_key] = '' # Get your own!
    SiteConfig[:publish_time] = 0    # Midnight
    SiteConfig[:theme] = "default"
    SiteConfig[:image_sizes] = {
      'thumbnail' => '100x100',
      'preview'   => '150x130',
      'avatars'   => [
        '100x100',
        '50x50'
      ],
      'screens'=> {
        'wide'    => [
          '1024x640',
          '1280x800',
          '1680x1050'
        ],
        'standard'=> [
          '1024x768',
          '1280x1024',
          '1600x1200'
        ]
      }
    }
    
    puts ""
    puts "Be sure and click the 'enable post-publishing' button in the Site Settings if you want to support post-dating comics!"
    puts ""
    puts "Finished!"
  end
  
  desc "Creates a crontab for publishing"
  task :crontab do
    require 'sequent/crontab'
    Sequent::create_crontab
  end
  
  task :reset =>['log:clear', 'tmp:clear'] do
    FileUtils.rm_rf("#{RAILS_ROOT}/public/media")
    FileUtils.rm("#{RAILS_ROOT}/db/development.sqlite3", :force=>true)
    FileUtils.rm("#{RAILS_ROOT}/log/crontab", :force=>true)
  end

end