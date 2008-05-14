set :application, "sequent"
set :repository, "http://mattmccray.com/svn/#{application}/trunk"
set :use_sudo, false
set :keep_releases, 1
set :checkout, "export"

# set :user, "UPDATE>MY_USERNAME"            # defaults to the currently logged in user

role :web, "UPDATE>MY_URL"
role :app, "UPDATE>MY_URL"
role :db,  "UPDATE>MY_URL", :primary => true


set :deploy_to, "/home/#{user}/apps/#{application}" # defaults to "/u/apps/#{application}"

# TASKS ------------------------------------------------------------------------------------

desc "Run app:setup on the remote app server"
task :run_setup, :roles=>[:app] do
  run "cd #{release_path} && rake app:setup RAILS_ENV=production"
end

desc "Run a remote task on the remote app server"
task :run_setup, :roles=>[:app] do
  raise "Please specify an action via the TASK environment variable" unless ENV['TASK']
  run "cd #{release_path} && rake #{ENV['TASK']} RAILS_ENV=#{ENV['RAILS_ENV'] || 'production'}"
end

desc "Spiffy deploy task"
task :deploy do
  also = (ENV["ALSO"] || '').split(/,/)
  transaction do
    disable_web
    update_code
    symlink
    migrate if also.include?('migrate')
  end
  restart
  enable_web
end

desc "Some extra-setup for Sequent"
task :after_setup do
  run 'mkdir #{deploy_to}/#{shared_dir}/media'
  run 'chmod 0777 #{deploy_to}/#{shared_dir}/media'
  run 'cp #{deploy_to}/#{shared_dir}/config/database.yml'
  run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.example.yml"
end

desc "Link in production database credentials and set permissions for FCGI"
task :after_update_code do
  # Link from a shared folder
  run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.yml"
  run "ln -nfs #{deploy_to}/#{shared_dir}/media #{release_path}/public/media"
  # Force production env...
  run %(ruby -i -pe '$_.sub!(/\\A\\# ENV\\[/, "ENV[")' #{release_path}/config/environment.rb)
  # Create a fastcgi.crash.log -- I'm sure it'll be used
  run "touch #{deploy_to}/#{shared_dir}/log/fastcgi.crash.log"
  run "touch #{deploy_to}/#{shared_dir}/log/production.log"
  # Set the permissions so FCGI doesn't whine so much...
  run "chmod 0666 #{deploy_to}/#{shared_dir}/log/fastcgi.crash.log"
  run "chmod 0666 #{deploy_to}/#{shared_dir}/log/production.log"
  run "chmod 0777 #{release_path}/public/media"
  run "chmod 0777 #{release_path}/tmp/*"
end

