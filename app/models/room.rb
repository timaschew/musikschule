class Room < ActiveRecord::Base
  has_many :courses
  has_many :small_rooms
  
  def name_and_id
    name + " (" + id.to_s + ")"
  end
  
end
