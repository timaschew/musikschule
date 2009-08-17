class CreateSchedules < ActiveRecord::Migration
  def self.up
    create_table :schedules do |t|
      t.integer :schedule_action_id, :null => false
      t.integer :course_id
      t.integer :room_id # can be the old / original; alias exist in model
      t.datetime :new_start # star time, can be the old / original
      t.datetime :new_end # end time, can be the old / original
      t.integer :flag, :default => 0
      t.integer :up_range , :default => 0
      t.integer :down_range, :default => 0
      
      t.timestamps
    end
  end

  def self.down
    drop_table :schedules
  end
end
