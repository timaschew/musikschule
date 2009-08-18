class SchedulesController < ApplicationController

  #ActiveRecord::Base.logger = Logger.new("log/schedules_controller.log") 
  ActiveRecord::Base.logger = Logger.new(STDOUT) 
  ActiveRecord::Base.logger.level = 0 # warn
  
  # Schedule Flags
  # -1 = could not scheduled
  # 0 = not initialized
  # 1 = initialized, not scheduled
  # 2 = scheduled, changed room
  # 3 = scheduled, changed time
  # 4 = scheduled, changed time and room
  # 5 = scheduled, recursivly
  
  # ATTENTION !!!
  # The Scheduler works only within one weekday, which is chosen by the user through the form
  
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
        :flag => 1
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
  	
  	
  	
  
	def index
		@rooms = Room.find(:all)
	end
	
	def debugging
	  
	  if session[:schedule].nil? || ScheduleAction.find(:all, :conditions => {:id => session[:schedule]}).empty?
	    render :text => "keine Session bzw. Datensätze vorhanden"
    else
      
      @action = ScheduleAction.find(session[:schedule])
      @step_b_courses = schedule_step_a(@action.id)
      
    end
	  
  end
	
	
	def search
	  
	  # if no session is set or the data is deleted from db, generate new Action and set new session
	  if session[:schedule].nil? || ScheduleAction.find(:all, :conditions => {:id => session[:schedule]}).empty?
      action = ScheduleAction.new
      action.save
      session[:schedule] = action.id
    end
    
    # get the action from DB
    @action = ScheduleAction.find(session[:schedule])
    # and save the user data from the form
    @action.busy_room = Room.find(params[:room_id].to_i)
    day = params[:date][0,2].to_i
    month = params[:date][3,2].to_i
    year = params[:date][6,4].to_i
    @action.date = Date.new(year, month, day)
    @action.busy_start = Time.mktime(0, 1, 1, params[:time]["start(4i)"], params[:time]["start(5i)"])
    @action.busy_end = Time.mktime(0, 1, 1, params[:time]["end(4i)"], params[:time]["end(5i)"])
    @action.flag = 1 # form values saved
    @action.save # save to DB
    
    @step_b_courses = schedule_step_a(@action.id) # return a list with not scheduled course IDs
    #@step_c_courses = schedule_step_b(@action.id, @step_b_courses) # return a list with not scheduled course IDs
    
  end
  
  def schedule_step_a(action_id)
    @action = ScheduleAction.find(action_id)
    
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
	
	

	def check
	  $call_this_method = 0
	  $smallFreeRooms = nil         # freie Räume, die aber zu klein sind in Schritt (A)
    $timeTableList = nil          # alle Kurse mit Informationen als Hash
	  
	  submitForm = params[:commit]
		
		# Prüfe ob Formular benutzt wurde
		if submitForm == "choose"
			
			# Parameter aus dem Forumlar auslesen
			$busyRoomID = params[:room_id].to_i   # Raum der nun belegt ist
			date = params[:date]             # Datum
			day = date[0,2]                 # Tag
			month = date[3,2]               # Monat
			year = date[6,4]                # Jahr
			date = Date.new(year.to_i, month.to_i, day.to_i) # echtes Datum
			$weekday = date.wday.to_i      # Wochentag als Zahl
			$weekdayString = date.strftime("%A")   # Wochentag als Name
			
			$busyStartH = params[:time]["start(4i)"] # Anfangszeitpunkt der Belegung (Stunde)
			$busyStartM = params[:time]["start(5i)"]  # Anfangszeitpunkt der Belegung (Minute)
			$busyEndH = params[:time]["end(4i)"]     # Endzeitpunkt der Belegung (Stunde)
			$busyEndM = params[:time]["end(5i)"]      # Endzeitpunkt der Belegung (Minute)
			
			# Alle Kurse an dem Tag in das Objekt @container laden
			getAllCoursesAtWeekday($weekday)
			$timeTableList # getTimeTable
			originalTimeTable = $timeTableList.dup
			
			$smallFreeRooms = []
			
			$scheduleCourses # Kurse die im Schritt (A) verschoben werden (gleiche Zeit, anderer Raum)
			$scheduleBCourses = []  # Kurse die im Schritt (B) verschoben werden (gleicher Raum, andere Zeit)
			
			
			# Pruefe welche Kurse in dem busy-Zeitraum und busy-Raum liegen und gebe Kurs-IDs als Array zurück
			$scheduleCourses = getCoursesToSchedule()
			
			# SCHRITT (A)
			# Fuer jeden Kurs der verschoben werden muss, suche einen freien Raum, zur gleichen Zeit
			$scheduleCourses.each_with_index do |cID, i|
			  course = Course.find(cID) # komplettes Objekt mit allen Feldern
				#size = Courselist.find_all_by_course_id(cID).count   # Größe des Kurses bestimmen
				size = 10
				newRoom = checkFreeRoomAtSameTime(size, course.id, course.start, course.duration)
				if !newRoom.nil? && newRoom != false
					changeRoom(course.id, newRoom)
				else
				  $scheduleBCourses.push(cID)
					# Raum bleibt in $scheduleCourses und es wirt Schritt 3b angewandt
				end
			end # Schritt (A)
			
			if !$scheduleBCourses.empty?
			  render :template => "schedules/setTimeDistance"
		  end
			
			
		end # POST Aktion
	end # check Methode
	
	
	def continueChecking
	  
	  logger.debug "Parameters: #{params.inspect}"
	  
	  @scheduleCCourses = []  # Kurse die im Schritt (C) verschoben werden (anderer Raum, andere Zeit)
	  logger.debug "couuuuunter: #{$call_this_method.inspect}"
	  $call_this_method = $call_this_method.to_i # beim ersten Aufruf = 0, sonst alter Wert
	  if $call_this_method == 0 || (params[:test] == 1 unless params[:test].nil?)
	    $call_this_method += 1
	    @scheduleHashCourses = []
      # Parameter aus dem Benutzer-Formular auslesen
  	  $scheduleBCourses.each_with_index do |cID, i| 
  	    tmpHash = {}
  	    tmpHash[:course] = cID
    		startHour = params[:time][""+cID.to_s+"_start(4i)"].to_i # Anfangszeitpunkt der Belegung (Stunde)
    		startMin = params[:time][""+cID.to_s+"_start(5i)"].to_i  # Anfangszeitpunkt der Belegung (Minute)
    		endHour = params[:time][""+cID.to_s+"_end(4i)"].to_i     # Endzeitpunkt der Belegung (Stunde)
    		endMin = params[:time][""+cID.to_s+"_end(5i)"].to_i      # Endzeitpunkt der Belegung (Minute)
    		tmpHash[:limitStart] = Time.mktime(0, 1, 1, startHour, startMin)
    		tmpHash[:limitEnd] = Time.mktime(0, 1, 1, endHour, endMin)
  	    @scheduleHashCourses[i] = tmpHash # altes Array mit Kurs-IDs mit Hash überschreiben
  	  end
	  
  	  logger.debug "scheduleHashCourses: #{@scheduleHashCourses.inspect}"
  	  #logger.debug ""
      #logger.debug "timeTableList: #{$timeTableList.inspect}"
	  
  	  @scheduleHashCourses.each do |hashmap|
  	    cID = hashmap[:course]
  	    logger.debug "hashmap: #{hashmap.inspect}}"
  	    # als erstes im selben Raum prüfen
  	    courseRoom = Course.find(cID).room_id
  	    #logger.debug "getForCourse(#{cID})"
        oldStartTime = getForCourse(cID)[:startTime] # original Time
        oldEndTime = getForCourse(cID)[:endTime] # original Time
  	    limitUp = oldStartTime - hashmap[:limitStart] # Zeitdifferenz nach oben
  	    limitDown = hashmap[:limitEnd] - oldStartTime # Zeitdifferenz nach unten
  	    offset = 3600 # init (Stundenweise), alternativ 1800 oder 900 (halbe Stunde oder viertel Stunde)
	    
  	    result = checkNewTimeWithRange(offset, limitUp, limitDown, cID, courseRoom, oldStartTime, oldEndTime)
		  
  		  if !result
  		    @scheduleCCourses.push(cID)
  	    end
		  
  		  logger.debug ""
  		  #logger.debug "#{$timeTableList.inspect}"
  		  logger.debug ""
	    
      end
    end
    
  end
	
	
	private
	
=begin
  Es werden die Kurse gesucht, die verschoben werden müssen
  Also: Suche alle Kurse, 
  	die im passenden Raum,
  	die innerhalb des Zeitraums,
  		(entweder umschließt der Zeitraum des Kurstermin ORDER
  		 der Kurs beginnt vor dem Zeitraum und endet darin ODER 
  		 der Kurs beginnt im Zeitraum und endet danach)
  	stattfinden.
  	Diese werden in einem Array gespeichert und als Rückgabewert übergeben
=end

    def getCoursesToSchedule()
  		#setze Zeit zusammen
  		busyStartTime = $busyStartH + ":" + $busyStartM
  		busyEndTime = $busyEndH + ":" + $busyEndM
  		courseList = Course.find(
  			:all,
  			:conditions => [
  				"room_id = ? AND weekday = ? 
  				AND 
  				(
  					((start BETWEEN ? AND ?) AND (duration BETWEEN ? AND ?))
  					OR
  					(start < ? AND duration > ?)
  					OR
  					(start < ? AND duration > ?)
  				)",
  				$busyRoomID, $weekday, 
  				busyStartTime, busyEndTime, busyStartTime, busyEndTime,
  				busyStartTime, busyStartTime,
  				busyEndTime, busyEndTime
  			],
  			:order => "start"
  		).map(&:id)
  		courseList # return value
  	end

=begin
  Suche für Kurs (courseID) der in der jeweiligen Zeit stattfindet
  einen Ersatzraum, der frei ist, außer notRoom (dieser ist nämlich gesperrt)
  Wenn ein Raum gefunden gib Raumnumme zurück, sonst -1
=end
  	def checkFreeRoomAtSameTime(size, courseID, startDate, endDate) 
  		#startTime = startDate.strftime("%H") + ":" + startDate.strftime("%M")
  	  #endTime = endDate.strftime("%H")  + ":" + endDate.strftime("%M") 
  		freeRoom = nil
  		
  		allRooms = Room.find(:all, :order => "size").map(&:id)
  		allRooms.each do |r|
  		  if r == $busyRoomID
  		    next 
		    end
  		  
  			# prüfe ob der Kurs für die jeweilige Zeit frei ist
  			roomHasCourses = []
  			roomHasCourses = checkNewTimeAndRoom(r, startDate, endDate) 
    		
  			if roomHasCourses.empty?
  				# Raum ist in diesem Zeitraum frei, Kurs kann in diesem Raum nun verschoben werden
  				# Prüfe ob Raumgröße ausreichend ist
  				if Room.find(r).size >= size
  				  # Raum passt
  				  freeRoom = r
  			  else
  			    # Raum ist zu klein, aber merke es evtl für später
  			    $smallFreeRooms.push(Hash.[](
  			    :start, Time.mktime(0, 1, 1, startDate.strftime("%H").to_i, startDate.strftime("%M").to_i), 
  			    :end, Time.mktime(0, 1, 1, endDate.strftime("%H").to_i, endDate.strftime("%M").to_i), 
  			    :room, r))
  		    end
  		    
		    else
		      # Raum ist belegt hier wäre Schritt 3b dran
		      # aber das ganze in einer anderen Methode
	      end
      end
  		    
  		# Rückgabewert
  		if freeRoom.nil?
  		  false
		  else
		    freeRoom
	    end
  	end

=begin
  Suche für Kurs (courseID) der in der jeweiligen Zeit stattfindet
  einen Ersatzraum, der frei ist
  Wenn ein Raum gefunden gib Raumnumme zurück, sonst -1
=end
  	def checkRoomAtOtherTime(courseID, room, startTime)
  	  # TODO: darf hier in der DB gesucht werden????? es müsste eigenltich in $timeTableList gesucht werden !
  	  oldStart = Course.find(courseID).start
  	  oldEnd = Course.find(courseID).duration
  	  duration = oldEnd - oldStart
  	  
  	  #room = Course.find(courseID).room_id
  		freeTime = 0
      alreadyCourses = checkNewTimeAndRoom(room, startTime, startTime + duration)

      if alreadyCourses.empty?
        freeTime = 1
        logger.debug "Kurs #{courseID}: #{Course.find(courseID).name} kann in Raum #{room} stattfinden von #{startTime.strftime("%H")} bis #{(startTime + duration).strftime("%H")}"
      end
      
      freeTime # return value
  	end

=begin
  Prüfe ob zu dem jeweiligen Zeitraum im jeweiligen Raum schon ein Kurs stattfindet
  auf Basis der Daten in $timeTableList
=end
  def checkNewTimeAndRoom(r, startDate, endDate)
    alreadyCourses = []
    $timeTableList.each do |l|
      #logger.debug "#{r.to_s} ==  #{l[:room].to_s}"
      if r == l[:room]  # Prüfe auf gleichen Raum
        #logger.debug "\tTRUE: #{r.to_s} ==  #{l[:room].to_s}"
        c1 = startDate - l[:startTime] < 0 && endDate - l[:startTime] > 0 # Start ist vorher, Ende liegt aber im/nach Zeitraum
        c2 = startDate - l[:endTime] < 0 && endDate - l[:endTime] > 0 # Start liegt im/vor Zeitraum, Ende außerhalb
        c3 = startDate.between?(l[:startTime], l[:endTime]) && endDate.between?(l[:startTime], l[:endTime]) # Start und Ende liegen innerhalb des Zeitraums
        #logger.debug "\t\t Kurs: #{l[:course]} = #{l[:startTime].to_s} bis #{l[:endTime].to_s}"
        #logger.debug "\t\t\t c1: #{c1.to_s} - c2: #{c2.to_s} - c3: #{c3.to_s}"
        if c1 || c2 || c3
          alreadyCourses.push(l[:course])
        end
      end
    end # Schleife
    #logger.debug "1. Laenge: #{alreadyCourses.count}"
    alreadyCourses
  end
  
  
  # Methode ist in Bearbeitung...
  def checkNewTimeWithRange(offset, limitUp, limitDown, cID, courseRoom, oldStartTime, oldEndTime)
    step = offset
	  #limit = 3 # Limit (immer in Stunden, 0,5 = halbe Stunde, 0.25 = viertel Stunde)
	  #range = limit * (3600/offset)
	  rangeUp = limitUp.abs / offset
	  rangeDown = limitDown.abs / offset
	  range = rangeUp > rangeDown ? rangeUp.to_i : rangeDown.to_i # max. Range
    changed = false
	  
	  course = Course.find(cID) # komplettes Objekt mit allen Feldern
	  
	  logger.debug "suche neue Zeit für Kurs #{course.id}: #{course.name} von #{oldStartTime.strftime("%H")} bis #{oldEndTime.strftime("%H")}"
	  logger.debug "rangeUp = #{rangeUp} ; rangeDown = #{rangeDown} ; range = #{range}"
	  doubleRange = 2 * range
    doubleRange.times do |i|
	    logger.debug "i = #{i} || offset = #{offset}"
	    # Wenn Limit nach oben und unten sich unterscheiden
	    # offset für nächste Iteration anpassen
	    if i % 2 == 1 && rangeUp < ((i+1)/2) # @ 1,3,5,7, ...
	      offset *= -1
	      offset += step
	      logger.debug "rangeUp < i == #{rangeUp.to_s} < #{i.to_s}"
	      next # continue
      end
      if i % 2 == 0 && rangeDown < ((i+1)/2) # @ 0,2,4,6, ...
        offset *= -1
        logger.debug "rangeDown < i == #{rangeDown.to_s} < #{i.to_s}"
        next # continue
      end
	    
	    newStartTime = oldStartTime + offset
	    newEndTime = oldEndTime + offset
	    busyTimeStart = Time.mktime(0, 1, 1, $busyStartH.to_i, $busyStartM.to_i)
	    busyTimeEnd = Time.mktime(0, 1 , 1, $busyEndH.to_i, $busyEndM.to_i)
	    # den selben Raum nur prüfen, wenn es außerhalb des besetzten Zeitraums liegt
	    if newStartTime.between?(busyTimeStart+1, busyTimeEnd-1) || newEndTime.between?(busyTimeStart+1, busyTimeEnd-1) # exklusiv hack
	      logger.debug "\t Zeit liegt innerhalb der busyTime #{newStartTime.strftime("%H")}:#{newStartTime.strftime("%M")} - #{newEndTime.strftime("%H")}:#{newEndTime.strftime("%M")}"
      else
		    logger.debug "\t Zeit liegt außerhalb #{newStartTime.strftime("%H")}:#{newStartTime.strftime("%M")} - #{newEndTime.strftime("%H")}:#{newEndTime.strftime("%M")}"
		    result = checkRoomAtOtherTime(cID, courseRoom, newStartTime)
		    if result == 1
		      changeTime(cID, newStartTime)
		      changed = true
		      logger.debug "\t \t Kurs wird nun verschoben werden nach: #{newStartTime.strftime("%H")}"
		      break
        else 
          logger.debug "\t \t Zeit besetzt"
        end
        
        #logger.debug "Zeit ist frei: #{result.nil? ? false.to_s : true.to_s}"
        
      end
      logger.debug "------------"
      # Offset für nächste Iteratino anpassen
	    if i % 2 == 0
	      offset *= -1 # alternating: @ 0,2,4,6, ...
	    else
	      offset *= -1 # alternating: @ 1,3,5,7, ...
	      offset += step
      end
    end # doubleRange.times Loop
    changed # return value
  end

=begin
  Instanzvariablen werden initialisiert
  und es werden alle Kurse für den Tag weekday in die $timeTableList geladen
=end
  def getAllCoursesAtWeekday(weekday)
    $timeTableList = []
    courses = Course.find(:all, :conditions => {:weekday => weekday}, :order => :start)
    courses.each do |c|
      insertCourse(
        c.id, c.room_id, 
        c.start.strftime("%H"), 
        c.start.strftime("%M"), 
        c.duration.strftime("%H"), # end
        c.duration.strftime("%M")) # end
    end
	  #logger.debug "#{$timeTableList.inspect}"
  end

=begin
  Jedes Element in $timeTableList hat einen Hash mit Informationen zu Kurs-ID, Raum-ID, Zeitraum (Anfang und Ende)
=end
  def insertCourse(courseID, roomID, startHour, startMin, endHour, endMin)
    entry = {}
    entry[:course] = courseID
    entry[:room] = roomID
    entry[:startTime] = Time.mktime(0, 1, 1, (startHour.to_i), startMin)
    entry[:endTime] = Time.mktime(0, 1, 1, (endHour.to_i), endMin)
    $timeTableList.push(entry)
  end

=begin
  Es wird das Element (Hash) mit dem passenden Kurs zurückgegeben, 
  wird per Kurs-ID bestimmt
=end
  def getForCourse(courseID)
    val = -1
    $timeTableList.each do |l|
      if l[:course] == courseID
        val = l
        break
      end
    end
    val # return value
  end

=begin
  die $timeTableList wird verändert, der entsprechende Kurs bekommt einen neuen Raum zugewiesen
=end
  def changeRoom(cID, rID)
    $timeTableList.each_with_index do |t, i|
      if cID.to_i == t[:course].to_i
        #@messages.push("Changing Room: Kurs " + cID.to_s + " von " + t[:room].to_s + " nach " + rID.to_s)
        logger.debug "Changing Room: Kurs #{cID.to_s} von #{t[:room].to_s}  nach #{rID.to_s}"
        $timeTableList[i][:room] = rID
        $timeTableList[i][:changed] = 1
      end
    end
  end

=begin
  die $timeTableList wird verändert, der entsprechende Kurs bekommt eine neue Zeit zugewiesen
=end
  def changeTime(cID, startTime)
    $timeTableList.each_with_index do |t, i|
      if cID.to_i == t[:course].to_i
        #@messages.push("Changing Room: Kurs " + cID.to_s + " von " + t[:room].to_s + " nach " + rID.to_s)
        logger.debug "Changing Time: Kurs #{cID.to_s} von #{t[:startTime].to_s} nach #{startTime})"
        duration = $timeTableList[i][:endTime] - $timeTableList[i][:startTime]
        $timeTableList[i][:startTime] = startTime
        $timeTableList[i][:endTime] = startTime + duration
        $timeTableList[i][:changed] = 1
      end
    end
  end
end
