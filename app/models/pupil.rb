class Pupil < ActiveRecord::Base
  has_many :courselists
  
  def get_full_name
    "#{lastname}, #{firstname}"    
  end
end
