module SchedulesHelper
  
=begin
  Instanzvariablen werden initialisiert
  und es werden alle Kurse für den Tag weekday in die @timeTableList geladen
=end
  def init(weekday)
    @timeTableList = []
    @timeTableCount = []
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
	  #logger.debug "#{@timeTableList.inspect}"
  end
  
=begin
  Jedes Element in @timeTableList hat einen Hash mit Informationen zu Kurs-ID, Raum-ID, Zeitraum (Anfang und Ende)
=end
  def insertCourse(courseID, roomID, startHour, startMin, endHour, endMin)
    entry = {}
    entry[:course] = courseID
    entry[:room] = roomID
    entry[:startTime] = Time.mktime(0, 1, 1, (startHour.to_i + 1), startMin).utc
    entry[:endTime] = Time.mktime(0, 1, 1, (endHour.to_i + 1), endMin).utc
    #entry[:startHour] = startHour
    #entry[:startMin] = startMin
    #entry[:endHour] = endHour
    #entry[:endMin] = endMin
    @timeTableList.push(entry)
  end
  
=begin
  Es wird das Element (Hash) mit dem passenden Kurs zurückgegeben, 
  wird per Kurs-ID bestimmt
=end
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
  
  
  
=begin
    Es wird das Element (Hash) mit dem passenden Kurs zurückgegeben,
    wird per Zeit und Raum bestimmt (nur mit dieser Kombination ist der Kurs eindeutig)
=end
  def getForStartTimeAndRoom(startHour, startMin, roomID)
    startTime = Time.mktime(0, 1, 1, (startHour + 1), startMin).utc
    val = nil
    @timeTableList.each do |l|
      if l[:room].to_i == roomID.to_i && l[:startTime] == startTime
        #logger.debug "Zeitvergleich: true; Raum #{roomID}; Kurs #{l[:course]}" 
        val = l
        break
      end
    end
    val # return
  end
  
  
=begin
  die @timeTableList wird verändert, der entsprechende Kurs bekommt einen neuen Raum zugewiesen
=end
  def changeRoom(cID, rID)
    @timeTableList.each_with_index do |t, i|
      if cID.to_i == t[:course].to_i
        #@messages.push("Changing Room: Kurs " + cID.to_s + " von " + t[:room].to_s + " nach " + rID.to_s)
        logger.debug "Changing Room: Kurs #{cID.to_s} von #{t[:room].to_s}  nach #{rID.to_s}"
        @timeTableList[i][:room] = rID
        @timeTableList[i][:changed] = 1
      end
    end
  end

=begin
  die @timeTableList wird verändert, der entsprechende Kurs bekommt eine neue Zeit zugewiesen
=end
  def changeTime(cID, startTime)
    @timeTableList.each_with_index do |t, i|
      if cID.to_i == t[:course].to_i
        #@messages.push("Changing Room: Kurs " + cID.to_s + " von " + t[:room].to_s + " nach " + rID.to_s)
        logger.debug "Changing Time: Kurs #{cID.to_s} von #{t[:startTime].to_s} nach #{startTime})"
        @timeTableList[i][:startTime] = startTime
        @timeTableList[i][:changed] = 1
      end
    end
  end
  
end
