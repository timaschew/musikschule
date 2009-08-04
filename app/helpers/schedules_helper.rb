module SchedulesHelper
  
=begin
    Es wird das Element (Hash) mit dem passenden Kurs zurückgegeben,
    wird per Zeit und Raum bestimmt (nur mit dieser Kombination ist der Kurs eindeutig)
=end
  def getForStartTimeAndRoom(startHour, startMin, roomID)
    startTime = Time.mktime(0, 1, 1, (startHour + 1), startMin).utc
    val = nil
    $timeTableList.each do |l|
      if l[:room].to_i == roomID.to_i && l[:startTime] == startTime
        #logger.debug "Zeitvergleich: true; Raum #{roomID}; Kurs #{l[:course]}" 
        val = l
        break
      end
    end
    val # return
  end
  
end
