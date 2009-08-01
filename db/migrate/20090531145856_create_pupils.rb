class CreatePupils < ActiveRecord::Migration
  def self.up
    create_table :pupils do |t|
      t.string :firstname
      t.string :lastname
      t.string :phone
      t.date :birthday
      t.boolean :gender
      t.integer :flags
      t.text :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :pupils
  end
end
