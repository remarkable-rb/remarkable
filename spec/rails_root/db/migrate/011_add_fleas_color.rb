class AddFleasColor < ActiveRecord::Migration
  def self.up
    add_column :fleas, :color, :string
    
  end

  def self.down
    remove_column :fleas, :color
  end
end