class Schedule < ActiveRecord::Base
  belongs_to :schedule_action
  belongs_to :course
  belongs_to :room
  
  def start
    self.new_start
  end
  
  def duration
    self.new_end
  end
  
  # alias for room
  def new_room
    self.room
  end
  
  # alias for room = 
  def new_room=(value)
    self.room = value
  end
  
  def new_room_id
    self.room_id
  end
  
  def new_room_id=(value)
    self.room_id = value
  end
  
end
