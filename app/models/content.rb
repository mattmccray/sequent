class Content < ActiveRecord::Base

  has_many :comments, :as=>:commentable, :dependent=>:destroy, :conditions=>['is_spam = ?', false]

  # Specific types as a helper...
  has_many :attachments, :as=>:assetowner, :dependent=>:destroy

  rendered_column :body do |content, ctx|
    Sequent::Context.init(ctx)
    ctx['this'] = content.to_liquid
  end
  
  acts_as_sluggable :source_column => 'title', :target_column => 'slug' #, :scope => 'type'

  def to_liquid
    Sequent::Drops::ContentDrop.new self
  end
  
  def published_on
    self[:created_on]
  end

end
