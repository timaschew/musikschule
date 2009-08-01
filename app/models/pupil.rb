class Pupil < ActiveRecord::Base
  has_many :courses
  has_many :courselists
end
