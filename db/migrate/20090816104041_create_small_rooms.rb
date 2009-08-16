class CreateSmallRooms < ActiveRecord::Migration
  def self.up
    create_table :small_rooms do |t|
      t.integer :schedule_action_id
      t.integer :room_id

      t.timestamps
    end
  end

  def self.down
    drop_table :small_rooms
  end
end
