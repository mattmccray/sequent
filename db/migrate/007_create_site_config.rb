class CreateSiteConfig < ActiveRecord::Migration
  def self.up
    create_table :site_config do |t|
      t.column :key, :string, :null=>false
      t.column :value, :text, :default=>""
    end
    
    add_index :site_config, :key
  end

  def self.down
    drop_table :site_config
  end
end
