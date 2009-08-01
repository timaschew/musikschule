class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table :courses do |t|
      t.string :name
      t.integer :teacher_id
      t.integer :subject_id
      t.integer :room_id
      t.time :start
      t.time :duration
      t.integer :weekday
      t.boolean :coursetype
      t.boolean :honorartype
      t.decimal :honorar, :precision => 8, :scale => 2
      t.text :comment

      t.timestamps
    end
  end

  def self.down
    drop_table :courses
  end
end
