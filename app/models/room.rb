class Room < ActiveRecord::Base
  has_many :courses
  has_many :small_rooms
end
