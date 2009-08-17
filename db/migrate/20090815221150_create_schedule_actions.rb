class CreateScheduleActions < ActiveRecord::Migration
  def self.up
    create_table :schedule_actions do |t|
      
      t.integer :room_id
      t.datetime :busy_start
      t.datetime :busy_end
      t.date :date
      t.integer :flag, :default => 0
      
      t.timestamps
    end
  end

  def self.down
    drop_table :schedule_actions
  end
end
