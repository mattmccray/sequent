class Page < ActiveRecord::Base
  acts_as_sluggable :source_column => 'title', :target_column => 'url_slug', :scope => :parent

end