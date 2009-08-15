class CreateScheduleActions < ActiveRecord::Migration
  def self.up
    create_table :schedule_actions do |t|
      
      t.integer :room_id
      t.time :busy_start
      t.time :busy_end
      t.integer :flag, :default => 0
      
      t.timestamps
    end
  end

  def self.down
    drop_table :schedule_actions
  end
end
