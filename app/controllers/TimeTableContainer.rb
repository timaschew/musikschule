class TimeTableContainer
  
  @timeTableList = nil
  @messages = nil
  
  def getTimeTable
    @timeTableList
  end
  
  def getMessages
    @messages
  end
  
  def initialize(weekday)
    @timeTableList = []
    @messages = []
    courses = Course.find(:all, :conditions => {:weekday => weekday}, :order => :start)
    
    courses.each do |c|
      insertCourse(
        c.id, c.room_id, 
        c.start.strftime("%H"), 
        c.start.strftime("%M"), 
        c.duration.strftime("%H"), # end
        c.duration.strftime("%M")) # end
    end
    
  end
  
  def insertCourse(courseID, roomID, startHour, startMin, endHour, endMin)
    entry = {}
    entry[:course] = courseID
    entry[:room] = roomID
    entry[:startTime] = Time.mktime(0, 1, 1,startHour, startMin)
    entry[:endTime] = Time.mktime(0, 1, 1, endHour, endMin)
    #entry[:startHour] = startHour
    #entry[:startMin] = startMin
    #entry[:endHour] = endHour
    #entry[:endMin] = endMin
    @timeTableList.push(entry)
  end
  
  def getForCourse(courseID)
    val = -1
    @timeTableList.each do |l|
      if l[:course] == courseID
        val = l
        break
      end
    end
    val # return value
  end
  
  
  def getForTimeAndRoom(startHour, startMin, endHour, endMin, roomID)
    startTime = Time.mktime(0, 1, 1,startHour, startMin)
    endTime = Time.mktime(0, 1, 1, endHour, endMin)
    val = -1
    @timeTableList.each do |l|
      if l[:room] == roomID && l[:startTime] == startTime && l[:endTime] == endTime
        val = l
        break
      end
    end
    val # return
  end
  
  def changeRoom(cID, rID)
    @timeTableList.each_with_index do |t, i|
      if cID == t[:course]
        @messages.push("Changing Room: Kurs " + cID + " von " + t[:room] + " nach " + rID)
        @timeTableList[i][:room] = rID
      end
    end
  end
  
  
end