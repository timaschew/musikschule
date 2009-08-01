class Courselist < ActiveRecord::Base
  belongs_to :course
  belongs_to :pupil
end
