class Courselist < ActiveRecord::Base
  belongs_to :course
  belongs_to :pupil
  
  validates_uniqueness_of :pupil_id, :scope => :course_id, :message => "Sch&uuml;ler nimmt bereits am Kurs teil"
  
end
