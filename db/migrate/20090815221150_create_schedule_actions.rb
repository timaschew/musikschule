class CreateScheduleActions < ActiveRecord::Migration
  def self.up
    create_table :schedule_actions do |t|
      
      t.integer :busy_room
      t.time :busy_start
      t.time :busy_end
      t.integer :flag
      
      t.timestamps
    end
  end

  def self.down
    drop_table :schedule_actions
  end
end
