class CreateContents < ActiveRecord::Migration
  def self.up
    create_table :contents do |t|
      t.column :title,         :string
      t.column :slug,          :string
      t.column :body,          :text
      t.column :type,          :string
      t.column :created_on,    :datetime
      t.column :updated_on,    :datetime
    end
    add_index :contents, [:slug, :type]
  end

  def self.down
    remove_index :contents, [:slug, :type] 
    drop_table :contents
  end
end
