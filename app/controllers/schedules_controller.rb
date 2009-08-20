class SchedulesController < ApplicationController

  #ActiveRecord::Base.logger = Logger.new("log/schedules_controller.log") 
  ActiveRecord::Base.logger = Logger.new(STDOUT) 
  ActiveRecord::Base.logger.level = 0 # warn
  
  # Schedule Flags
  #-1 = not scheduled in step A
  #-2 = not scheduled in step B and B1
  #-3 = not scheduled in step C, no way to schedule it
  # 0 = not initialized
  # 1 = initialized, not scheduled
  # 2 = scheduled, changed room A 
  # 3 = scheduled, changed time B
  # 4 = scheduled, changed time and room B1
  # 5 = scheduled, recursivly C
  
  # ATTENTION !!!
  # The Scheduler works only within one weekday, which is chosen by the user through the form
  


	def index
		@rooms = Room.find(:all)
	end
	
	def debugging
	  
	  if session[:schedule].nil? || ScheduleAction.find(:all, :conditions => {:id => session[:schedule]}).empty?
	    render :text => "keine Session bzw. Datensätze vorhanden"
    else
      
      @id = 1
      @id = params[:id].to_i unless (params[:id].nil? || params[:id].blank?)
      
      @action = ScheduleAction.find(session[:schedule])
      @schedules = @action.schedules
      
      @step_b_courses = Schedule.find_all_by_schedule_action_id_and_flag(@action.id, -1)
      
      @step_c_courses = Schedule.find_all_by_schedule_action_id_and_flag(@action.id, -2)
      
      
    end
	  
  end
	
	
	def schedule_search
	  
	  # if no session is set or the data is deleted from db, generate new Action and set new session
	  if session[:schedule].nil? || ScheduleAction.find(:all, :conditions => {:id => session[:schedule]}).empty?
      action = ScheduleAction.new
      action.save
      session[:schedule] = action.id
    end
    
    # get the action from DB
    @action = ScheduleAction.find(session[:schedule])
    # and save the user data from the form
    @action.busy_room = Room.find(params[:room][:id].to_i)
    day = params[:date][0,2].to_i
    month = params[:date][3,2].to_i
    year = params[:date][6,4].to_i
    @action.date = Date.new(year, month, day)
    @action.busy_start = Time.mktime(0, 1, 1, params[:time]["start(4i)"], params[:time]["start(5i)"])
    @action.busy_end = Time.mktime(0, 1, 1, params[:time]["end(4i)"], params[:time]["end(5i)"])
    @action.flag = 1 # form values saved
    @action.save # save to DB
    
    @step_b_courses = schedule_step_a # return a list with not scheduled course IDs
    
    render :template => "schedules/before_step_b" unless @step_b_courses.empty?
    
    #@step_c_courses = schedule_step_b(@action.id, @step_b_courses) # return a list with not scheduled course IDs
    
  end
  

  def schedule_step_a
    @action = ScheduleAction.find(session[:schedule])
    @action.flag = 2
    @action.save
    
    # cleaning up old schedule objects in DB which associated with the actual action ID
    Schedule.find_all_by_schedule_action_id(@action.id).each do |s|
      s.destroy
    end
    SmallRoom.find_all_by_schedule_action_id(@action.id).each do |sm|
      sm.destroy
    end
    
    # get all courses at weekday and save it to @action.schedules
    # at this time they dont have to be scheduled, but its possible in the next steps
    get_courses_at_weekday(@action.date.wday)
    
    @schedules = @action.schedules
    
    # list with course IDs that collide with the busy_room and busy_time
    @clashed_courses = get_courses_to_schedule(@action)
    step_b_courses = []
    
    # STEP 1 / A (scheduling room)
    @scheduling_1 = {}
    @clashed_courses.each do |course_id|
      new_room_id = check_free_room_at_same_time(course_id, @action)
      update = Schedule.find_by_schedule_action_id_and_course_id(@action.id, course_id)
      if new_room_id != false
        update.new_room_id = new_room_id
        update.flag = 2
        update.save
        @scheduling_1[course_id] = new_room_id # only debug
      else
        update.flag = -1
        update.save
        step_b_courses.push(course_id)
        @scheduling_1[course_id] = false # only debug
      end
    end
    step_b_courses # return value
  end
	
	
	
  def schedule_step_b
    
    @action = ScheduleAction.find(session[:schedule])
    @step_b_courses = []
    
    
    # @step_b_courses = Schedule.find_all_by_schedule_action_id_and_flag(@action.id, -1).map(&:course_id) # alternativ
    params[:courses].each {|id| @step_b_courses.push id.to_i } # cast from string to integer
    
    @step_b_courses.each do |c_id|
      schedule_course = Schedule.find_by_schedule_action_id_and_course_id(@action.id, c_id)
      up_hour = params[:time][c_id.to_s + "_start(4i)"].to_i
      up_min = params[:time][c_id.to_s + "_start(5i)"].to_i
      down_hour = params[:time][c_id.to_s + "_end(4i)"].to_i
      down_min = params[:time][c_id.to_s + "_start(5i)"].to_i
      
      up_range = schedule_course.new_start - Time.mktime(0, 1, 1, up_hour, up_min)
      down_range = Time.mktime(0, 1, 1, down_hour, down_min) - schedule_course.new_end
      schedule_course.up_range = up_range > 0 ? up_range : 0 # no negative range
      schedule_course.down_range = down_range > 0 ? down_range : 0 # no negative range
      schedule_course.save
    end
    
    @updated_b_courses = Schedule.find_all_by_schedule_action_id_and_flag(@action.id, -1)
    
    @updated_b_courses.each do |schedule_course|
      offset = 3600 # step and offset
      check_new_time_with_range(offset, schedule_course)
    end
     
     @step_c_courses = Schedule.find_all_by_schedule_action_id_and_flag(@action.id, -2)

     schedule_step_c
    
  end
  
  
  def schedule_step_c
    
    @action = ScheduleAction.find(session[:schedule])
    schedule_courses = Schedule.find_all_by_schedule_action_id_and_flag(@action.id, -2)
    
    schedule_courses.each do |s|
      possible_room_ids = Room.find_all_by_size(s.course.size..99).map(&:id)
      small_room_ids = SmallRoom.find_all_by_schedule_action_id(@action.id).map(&:room_id).uniq
      
      rekursive_scheduler(small_room_ids, s.id, possible_room_ids, s.start, s.stop)
    end
    
  end
  
  private 
  
  
  # 
  def rekursive_scheduler(small_room_ids, g_schedule_id, g_possible_room_ids, g_start_time, g_end_time)
    
    small_room_ids.each do |r_id|
      # TODO: Optimierungsmöglichkeit: gleich danach suchen, dass die Course.size nicht größer als die Raum.size ist
      rekursive_courses = Schedule.all(
        :conditions => [
          "id != :c_id
          AND
          flag != 5
          AND
          (new_start <= :start AND new_end >= :stop)",
          {:start => g_start_time, :stop => g_end_time, :c_id => g_schedule_id}
        ]
      )
      
      rekursive_courses.each do |s|
        tmp = free_space_and_enough_seats(r_id, s.start, s.stop, s.course.size)
        if tmp == true # course can move to the small room, old course room is now free
          
          free_room_id = s.room_id
          s.new_room_id = r_id
          s.flag = 5
          s.save
          
          # g_possible_room_list contains free_room_id ?
          if g_possible_room_ids.detect {|x| x == free_room_id} == free_room_id 
            update = Schedule.find(g_schedule_id)
            update.new_room_id = free_room_id
            update.flag = 6
            update.save
            
            # return free_room_id
            
          else
            # call method recursvly with new data
            
            # update small_room_ids 
            small_room_ids.delete(r_id)
            small_room_ids.push(free_room_id)
            
            rekursive_scheduler(small_room_ids, g_possible_room_ids, g_course_id, g_start_time, g_end_time)
            
            
          end
          
        else
          
          # next course
          
        end # course loop
        
        # next small room
        
      end # room loop
      
    end # method
    
    
  end
  
=begin
Search all courses at the chosen weekday by the user
=end
  def get_courses_at_weekday(weekday)
    # all courses at weekday
    courses = Course.find_all_by_weekday(weekday, :order => :start)
    courses.each do |c|
      s = Schedule.create(
        :schedule_action => @action, 
        :course_id => c.id, 
        :new_room_id => c.room.id, # original room id
        :new_start => c.start, # original start time
        :new_end => c.duration, # original end time
        :flag => 1 # initialized
      )

      # backup original
      #original = Schedule.new
      #original.copy_instance_variables_from(Schedule.find(s.id))
      ##original.id = nil # delete Primary Key 
      #original.flag = -1 # set Flag
      #original.save
    end
  end

=begin
Search courses, that have a collision with the busy_room and busy_time (start and end)
return a list with the course IDs
=end
  def get_courses_to_schedule(action)
    # courses which begins between the busy time
    clash_start = Schedule.all(
      :conditions => {
        :room_id => action.busy_room.id,
        :new_start => action.busy_start..action.busy_end-1
      }
    ).map(&:course_id)
    # courses which ends between the busy time
    clash_end = Schedule.all(
      :conditions => {
        :room_id => action.busy_room.id,
        :new_end => action.busy_start+1..action.busy_end
      }
    ).map(&:course_id)
  	clash_start | clash_end # OR conjunction, return value
  end

=begin
search new room for course, same / old time
return true room_id if a room is found, otherwise false
=end
  def check_free_room_at_same_time(course_id, action) 
    schedule_course = Schedule.find_by_schedule_action_id_and_course_id(action.id, course_id)
    size = Course.find(course_id).courselists.count
  	free_room_id = false

  	all_rooms = Room.all(:order => :size).map(&:id)
  	all_rooms.each do |r_id|

  	  if r_id == action.busy_room.id # skip busy_room
  	    next 
      end

      # check free room for the course (same/old time) 
  		if free_space(r_id, schedule_course.new_start, schedule_course.new_end) == true
  			# room is free at the time, the course keeps the original time, but room will be changed now
  			# check if the room has enough seats for course size

  			if Room.find(r_id).size >= size
  			  # room has enough seats
  			  free_room_id = r_id
  			  logger.debug ">>>>>>>>>>>> Raum: #{r_id} frei und Platz}"
  			  break
  		  else
  		    # room has not enough seats, but it could used for recursive scheduling, save the room ID
  		    tmp = SmallRoom.new(
  		      :schedule_action_id => action.id,
  		      :room_id => r_id,
  		      :start => schedule_course.new_start,
  		      :end => schedule_course.new_end
  		    )
  		    if SmallRoom.all(
  		      :conditions => {
  		        :schedule_action_id => tmp.schedule_action_id,
  		        :room_id => tmp.room_id,
  		        :start => tmp.start,
  		        :end => tmp.end
  		      }
  		    ).count == 0
  		      tmp.save
  	      end
  		    logger.debug ">>>>>>>>>>>> Raum: #{r_id} frei aber kein Platz}"
  	    end # size
      end # free_room
    end # all_rooms

    free_room_id # return value
  end


# return true, if room is free between new_start and new_end
  def free_space(r_id, new_start, new_end)
  	tmp_courses_1 = Schedule.all(
  	  :conditions => {
  	    :room_id => r_id,
  	    :new_start => new_start..new_end-1
  	  }
  	).map(&:course_id)
  	tmp_courses_2 = Schedule.all(
  	  :conditions => {
  	    :room_id => r_id,
  	    :new_end => new_start+1..new_end
  	  }
  	).map(&:course_id)
  	room_has_courses = tmp_courses_1 | tmp_courses_2
  	room_has_courses.empty?
  end
  
# return true, if room is free between new_start and new_end and the room has enough seats
  def free_space_and_enough_seats(r_id, new_start, new_end, course_size)
  	tmp = free_space(r_id, new_start, new_end)
  	tmp && (Room.find(r_id).size >= course_size) # return value
  end

  def check_new_time_with_range(offset, schedule_course)
    course = schedule_course.course
    flag = -2
    @action = ScheduleAction.find(session[:schedule])
    step = offset
    #limit = 3 # Limit (immer in Stunden, 0,5 = halbe Stunde, 0.25 = viertel Stunde)
    #range = limit * (3600/offset)
    range_up = (schedule_course.up_range / offset).to_i
    range_down = (schedule_course.down_range / offset).to_i
    range = range_up > range_down ? range_up : range_down # max. Range
    logger.debug "+++++++++++++++++++++"
    logger.debug "suche neue Zeit für Kurs #{course.id}: #{course.name} beginnt noch um #{schedule_course.start.strftime("%H:%M")}"
    logger.debug "range_up = #{range_up} ; range_down = #{range_down} ; range = #{range}"
    double_range = 2 * range
    double_range.times do |i|
      logger.debug "i = #{i} || offset = #{offset}"
      # Wenn Limit nach oben und unten sich unterscheiden
      # offset für nächste Iteration anpassen
      if i % 2 == 1 && range_up < ((i+1)/2) # @ 1,3,5,7, ...
        offset *= -1
        offset += step
        logger.debug "range_up < i == #{range_up.to_s} < #{i.to_s}"
        next # continue
      end
      if i % 2 == 0 && range_down < ((i+1)/2) # @ 0,2,4,6, ...
        offset *= -1
        logger.debug "range_down < i == #{range_down.to_s} < #{i.to_s}"
        next # continue
      end

      new_start_time = schedule_course.start + offset
      new_end_time = schedule_course.stop + offset

      # den selben Raum nur prüfen, wenn es außerhalb des besetzten Zeitraums liegt
      if new_start_time.between?(@action.busy_start, @action.busy_end-1) || new_end_time.between?(@action.busy_start+1, @action.busy_end)
        logger.debug "\t Zeit liegt innerhalb der busyTime #{new_start_time.strftime("%H:%M")}- #{new_end_time.strftime("%H:%M")}"
        
      else
  	    logger.debug "\t Zeit liegt außerhalb #{new_start_time.strftime("%H:%M")}- #{new_end_time.strftime("%H:%M")}"
  	    result = free_space(schedule_course.room.id, new_start_time, new_end_time)
  	    if result == true
  	      schedule_course.start = new_start_time
  	      schedule_course.stop = new_end_time
  	      flag = 3
  	      logger.debug "\t \t Kurs wird nun verschoben werden nach: #{new_start_time.strftime("%H:%M")}"
  	      break
        else 
          logger.debug "\t \t Zeit besetzt"
          flag = -2
        end

        #logger.debug "Zeit ist frei: #{result.nil? ? false.to_s : true.to_s}"
      end
      
      # Schedule Step 3 (other rooms)
      inner_breaks =  false
      Room.all(:conditions => ["id != ?", @action.busy_room.id]).map(&:id).each do |r_id|
        result_2 = free_space_and_enough_seats(r_id, new_start_time, new_end_time, schedule_course.course.size)
        if result_2 == true
  	      schedule_course.start = new_start_time
  	      schedule_course.stop = new_end_time
  	      schedule_course.new_room_id = r_id
  	      flag = 4
  	      logger.debug "\t \t INNER: Kurs wird nun verschoben werden nach: #{new_start_time.strftime("%H:%M")} Raum: #{r_id}"
  	      inner_breaks = true
  	      break
	      else
	        logger.debug "\t \t INNER: Zeit besetzt"
  	      flag = -2
	      end
      end # room loop
      if inner_breaks == true
        break
      end
      
      
      logger.debug "------------"
      # Offset für nächste Iteratino anpassen
      if i % 2 == 0
        offset *= -1 # alternating: @ 0,2,4,6, ...
      else
        offset *= -1 # alternating: @ 1,3,5,7, ...
        offset += step
      end
      
      
    end # double_range.times Loop
    logger.debug "\t \t gar keine Zeit gefunden, flag = -2"
    schedule_course.flag = flag # set flag: -2 not scheduled; 3 scheduled and changed time
    schedule_course.save # save flag 

  end 
  
  
end
  

