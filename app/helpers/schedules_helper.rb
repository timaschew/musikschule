module SchedulesHelper
  
=begin
    Es wird das Element (Hash) mit dem passenden Kurs zurückgegeben,
    wird per Zeit und Raum bestimmt (nur mit dieser Kombination ist der Kurs eindeutig)
=end
  def getForStartTimeAndRoom(startHour, startMin, roomID)
    startTime = Time.mktime(0, 1, 1, startHour, startMin)
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
  
  def get_for_start_time_and_room(start, room_id)

    val = Schedule.all(
      :conditions => {
        :new_start => start.utc, # very important to use UTC, because in the DB the format is also UTC
        :room_id => room_id
      }
    )
    if val.count > 1
    end
    
    val.count == 1 ? val[0] : nil # return value
  end
end
