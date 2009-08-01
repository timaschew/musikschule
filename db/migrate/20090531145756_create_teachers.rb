require 'active_record/fixtures'  

class CreateTeachers < ActiveRecord::Migration
  def self.up
    create_table :teachers do |t|
      t.string :firstname
      t.string :lastname
      t.string :phone
      t.date :birthday
      t.text :comment

      t.timestamps
    end
    Fixtures.create_fixtures('test/fixtures', File.basename("teachers.yml", '.*'))
  end

  def self.down
    drop_table :teachers
  end
end
