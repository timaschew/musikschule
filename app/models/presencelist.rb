class Presencelist < ActiveRecord::Base
  belongs_to :pupil
  belongs_to :course
end
