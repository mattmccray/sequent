ActionController::Routing::Routes.draw do |map|

  # Resources:
  map.resources :sessions, :path_prefix => 'admin'
  map.resources :strips,   :path_prefix => 'admin' 
  map.resources :pages,    :path_prefix => 'admin' 
  map.resources :posts,    :path_prefix => 'admin' 
  map.resources :assets,   :path_prefix => 'admin'
  map.resources :users,    :path_prefix => 'admin'
  map.resources :comments, :path_prefix => 'admin'
  
  # The site controller isn't a resource
  map.site 'admin/site/:action/:id', :controller=>'site'
  
  # The the 'admin home page'
  map.admin_home 'admin', :controller=>'strips', :action=>'index'
  # The the 'admin home page'

  # Possible Asset URLs:
  # /assets/strips/:asset_id/*
  # /assets/attachments/:asset_id/*
  # /assets/wallpapers/:asset_id/*
  # /assets/avatars/:asset_id/*  
  map.media 'media/pending/*filename', :controller=>'media', :action=>'denied'
  map.media 'media/:asset_type/:id/*filename', :controller=>'media', :action=>'fetch'

  # RSS Feeds!
  map.feed  'feed/:action', :controller=>'feed'

  # Theme caching, good stuff
  map.theme 'themes/:theme/:action/*filename', :controller=>'theme'
  
  # Site rendering routes
  map.comic   'comic/:position',  :controller=>'sequent', :action=>'comic', :position=>nil
  map.content 'page/:slug', :controller=>'sequent', :action=>'page',  :slug=>nil
  map.news    'news/:slug', :controller=>'sequent', :action=>'news',  :slug=>nil
  map.connect 'add_comment',:controller=>'sequent', :action=>'add_comment'
  map.home    '', :controller=>'sequent', :action=>'home'
  
  # No default... If it's not defined, it doesn't exist! Bwaa-hah-haa!
  #map.connect ':controller/:action/:id'
end
