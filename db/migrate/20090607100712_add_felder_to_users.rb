class AddFelderToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :firstname, :string
    add_column :users, :lastname, :string
    add_column :users, :phone, :string
    add_column :users, :birthday, :date
    add_column :users, :comment, :text
  end

  def self.down
    remove_column :users, :comment
    remove_column :users, :birthday
    remove_column :users, :phone
    remove_column :users, :lastname
    remove_column :users, :firstname
  end
end
