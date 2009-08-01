class Course < ActiveRecord::Base
  belongs_to :teacher
  belongs_to :subject
  belongs_to :room
  has_many :courselists
  has_many :presencelists
end
