class CreateSmallRooms < ActiveRecord::Migration
  def self.up
    create_table :small_rooms do |t|
      t.integer :schedule_action_id, :null => false
      t.integer :room_id, :null => false
      t.datetime :start
      t.datetime :end

      t.timestamps
    end
  end

  def self.down
    drop_table :small_rooms
  end
end
