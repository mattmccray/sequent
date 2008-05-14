class Storyline < ActiveRecord::Base

  # this should serve as the storyline 'cover', if it has one
  has_one :attachment, :as=>:assetowner, :dependent=>:destroy

  # allow commenting on the storyline as a whole -- not sure if it'll be enabled on the UI at first 
  has_many :comments, :as=>:commentable, :dependent=>:destroy, :conditions=>['is_spam = ?', false]
  has_many :strips, :as=>:assetowner

  acts_as_list
  acts_as_sluggable :source_column => 'title', :target_column => 'slug'
  

  rendered_column :notes do |storyline, ctx|
    Sequent::Context.init(ctx)
    ctx['this'] = storyline.to_liquid
  end
  
  def to_liquid
    Sequent::Drops::StorylineDrop.new self
  end  

end
