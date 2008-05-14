class CreateStorylines < ActiveRecord::Migration
  def self.up
    create_table :storylines do |t|
      t.column :title,          :string
      t.column :slug,           :string
      t.column :notes,          :text
      t.column :position,       :integer, :default=>0
      t.column :created_on,     :datetime
      t.column :updated_on,     :datetime
    end
  end

  def self.down
    drop_table :storylines
  end
end
