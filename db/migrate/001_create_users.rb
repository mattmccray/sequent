class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column :login,                     :string
      t.column :salt,                      :string, :limit => 40
      t.column :crypted_password,          :string, :limit => 40
      t.column :display_name,               :string
      t.column :email,                     :string
      t.column :is_publisher,              :boolean, :default=>false
      t.column :created_on,                :datetime
      t.column :updated_on,                :datetime
      t.column :remember_token,            :string
      t.column :remember_token_expires_at, :datetime
    end
  end

  def self.down
    drop_table :users
  end
end
