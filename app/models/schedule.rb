class Schedule < ActiveRecord::Base
  belongs_to :schedule_action
  belongs_to :course
  belongs_to :room
  
  
  # alias for time
  def new_time
    self.time
  end
  
  # alias for time = 
  def new_time=(value)
    self.time = value
  end
  
  # alias for room
  def new_room
    self.room
  end
  
  # alias for room = 
  def new_room=(value)
    self.room = value
  end
  
end
