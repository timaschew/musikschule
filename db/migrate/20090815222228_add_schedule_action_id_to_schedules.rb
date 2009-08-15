class AddScheduleActionIdToSchedules < ActiveRecord::Migration
  def self.up
    add_column :schedules, :schedule_action_id, :integer
  end

  def self.down
    remove_column :schedules, :schedule_action_id
  end
end
