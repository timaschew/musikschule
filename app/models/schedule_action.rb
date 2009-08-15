class ScheduleAction < ActiveRecord::Base
  has_many :schedules
  belongs_to :room
  
  # alias for room
  def busy_room
    self.room
  end
  
  # alias for room = 
  def busy_room=(value)
    self.room = value
  end
  
end
