class AddFelderToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :firstname, :string
    add_column :users, :lastname, :string
  end

  def self.down
    remove_column :users, :comment
    remove_column :users, :birthday
  end
end
