module SchedulesHelper
  
# get schedule course with the specific time and room
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
