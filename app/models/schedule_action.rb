class ScheduleAction < ActiveRecord::Base
  has_many :schedules
  has_many :small_rooms
  belongs_to :room
  
  # alias for room
  def busy_room
    self.room
  end
  
  # alias for room = 
  def busy_room=(value)
    self.room = value
  end
  
  # list of room ids
  def get_small_rooms_ids
    self.small_rooms.map(&:room_id)
  end
  
  # list of room objects 
  def get_small_rooms
    room_list = []
    self.small_rooms.map(&:room_id).each {|id| room_list.push(Room.find(id))}
    room_list
  end
  
  
end
