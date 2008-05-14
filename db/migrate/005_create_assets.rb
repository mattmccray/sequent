class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.column :assetowner_id,   :integer
      t.column :assetowner_type, :string
      t.column :title,           :string  # optional -- for strip type
      t.column :slug,            :string  # optional -- for strip type
      t.column :meta,            :text
      t.column :filename,        :string
      t.column :mimetype,        :string
      t.column :notes,           :text
      t.column :is_published,    :boolean, :default=>true
      t.column :published_on,    :datetime
      t.column :position,        :integer, :default=>0
      t.column :type,            :string
      t.column :created_on,      :datetime
      t.column :updated_on,      :datetime
    end
    add_index :assets,   [:assetowner_id, :assetowner_type]
  end

  def self.down
    remove_index :assets,   [:assetowner_id, :assetowner_type]
    drop_table :assets
  end
end
