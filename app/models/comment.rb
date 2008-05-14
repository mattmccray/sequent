class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :commentable, :polymorphic=>true

  validates_presence_of :body, :on=>:create, :message=>"must be present"
  validates_presence_of :author, :on=>:create, :message=>"must be present"
  validates_presence_of :email, :on=>:create, :message=>"must be present"

  # Comments don't support any liquid tags...
  rendered_column :body, :preprocess=>false

  def to_liquid
    Sequent::Drops::CommentDrop.new self
  end

end
