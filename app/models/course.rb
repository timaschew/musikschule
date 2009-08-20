class Course < ActiveRecord::Base
  belongs_to :teacher
  belongs_to :subject
  belongs_to :room
  has_many :courselists
  has_many :presencelists
  
  def name_and_subject
    teacher.get_name + "<br/>" + subject.name
  end
  
  def get_name
    name.blank? ? "&lt;no name&gt;" : name
  end
  
  def teacher_and_subject
    teacher.get_name + "<br/>" + subject.name
  end
  
  def pretty_name
    subject.name + " bei " + teacher.get_name + " um " + start.strftime("%H") + ":" +start.strftime("%M") + " bis " + duration.strftime("%H") + ":" + duration.strftime("%M")
  end
  
  def size
    self.courselists.count
  end
  
end
