class CreateComments < ActiveRecord::Migration
  
  def self.up
    create_table :comments do |t|
      t.column :user_id,          :integer # Used for web-comic creators... Maybe
      t.column :commentable_id,   :integer
      t.column :commentable_type, :string
      t.column :body,             :text
      t.column :author,           :string
      t.column :url,              :string
      t.column :email,            :string
      t.column :ip_address,       :string
      t.column :user_agent,       :string
      t.column :http_referer,     :string
      t.column :is_spam,          :boolean, :default=>true
      t.column :created_on,       :datetime
      t.column :updated_on,       :datetime
    end
    add_index :comments, :user_id
    add_index :comments, [:commentable_id, :commentable_type]
  end

  def self.down
    remove_index :comments, :user_id
    remove_index :comments, [:commentable_id, :commentable_type]
    drop_table :comments
  end
end
