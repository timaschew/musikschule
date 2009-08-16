class SmallRoom < ActiveRecord::Base
  belongs_to :schedule_action
  belongs_to :room
end
