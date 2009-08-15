class Teacher < ActiveRecord::Base
  has_many :courses
  
  def get_name
    firstname[0,1] + ". " + lastname
  end
  
end