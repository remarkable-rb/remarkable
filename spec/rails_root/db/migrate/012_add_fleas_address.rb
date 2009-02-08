class AddFleasAddress < ActiveRecord::Migration
  def self.up
    add_column :fleas, :address, :string
    
  end

  def self.down
    remove_column :fleas, :address
  end
end