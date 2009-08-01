class CreateCourselists < ActiveRecord::Migration
  def self.up
    create_table :courselists do |t|
      t.integer :course_id
      t.integer :pupil_id
      t.date :register
      t.date :quit
      t.boolean :canceled
      t.text :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :courselists
  end
end
