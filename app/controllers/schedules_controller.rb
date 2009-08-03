class SchedulesController < ApplicationController
  include SchedulesHelper
  @smallFreeRooms = nil         # freie Räume, die aber zu klein sind in Schritt (A)
  @timeTableList = nil          # alle Kurse mit Informationen als Hash
  @messages = nil               # zum testen
  
	def index
		@rooms = Room.find(:all)
	end

	def check
	  #ActiveRecord::Base.logger = Log4r::Logger.new("Application Log") 
	  #ActiveRecord::Base.logger.level = 0 # at any time 
	  
	  ActiveRecord::Base.logger = Logger.new("Application Log") 
    ActiveRecord::Base.logger.level = 0 # warn 
    
	  
		@submit = params[:commit]
		
		# Prüfe ob Formular benutzt wurde
		if @submit == "choose"
			
			# Parameter aus dem Forumlar auslesen
			@roomID = params[:room_id].to_i   # Raum der nun belegt ist
			@date = params[:date]             # Datum
			@day = @date[0,2]                 # Tag
			@month = @date[3,2]               # Monat
			@year = @date[6,4]                # Jahr
			@date = Date.new(@year.to_i, @month.to_i, @day.to_i) # echtes Datum
			@weekdayNo = @date.wday.to_i      # Wochentag als Zahl
			@weekday = @date.strftime("%A")   # Wochentag als Name
			
			@startHour = params[:time]["start(4i)"] # Anfangszeitpunkt der Belegung (Stunde)
			@startMin = params[:time]["start(5i)"]  # Anfangszeitpunkt der Belegung (Minute)
			@endHour = params[:time]["end(4i)"]     # Endzeitpunkt der Belegung (Stunde)
			@endMin = params[:time]["end(5i)"]      # Endzeitpunkt der Belegung (Minute)
			
			# Alle Kurse an dem Tag in das Objekt @container laden
			init(@weekdayNo)
			@container = @timeTableList # getTimeTable
			@originalTimeTable = @container.dup
			
			@smallFreeRooms = []    # Kurse die im Schritt (A) verschoben werden (gleiche Zeit, anderer Raum)
			@scheduleBCourses = []  # Kurse die im Schritt (B) verschoben werden (gleicher Raum, andere Zeit)
			@scheduleCCourses = []  # Kurse die im Schritt (C) verschoben werden (anderer Raum, andere Zeit)
			
			# Pruefe welche Kurse fuer in dem Zeitraum und Raum liegen und gebe Kurs-IDs als Array zurück
			@scheduleCourses = getCoursesToSchedule(@roomID, @weekdayNo, @startHour, @startMin, @endHour, @endMin)
			
			# SCHRITT (A)
			# Fuer jeden Kurs der verschoben werden muss, suche einen freien Raum, zur gleichen Zeit
			@scheduleCourses.each_with_index do |cID, i|
			  course = Course.find(cID) # komplettes Objekt mit allen Feldern
				size = Courselist.find_all_by_course_id(cID).count   # Größe des Kurses bestimmen
				newRoom = checkFreeRoomAtSameTime(@weekdayNo, size, course.id, course.start, course.duration, @roomID)
				if !newRoom.nil? && newRoom != false
					changeRoom(course.id, newRoom)
					#@scheduleCourses.delete_at(i)
				else
				  @scheduleBCourses.push(cID)
					# Raum bleibt in @scheduleCourses und es wirt Schritt 3b angewandt
				end
			end # Schritt (A)
			
			@scheduleBCourses.each_with_index do |cID, i|
			  offset = 3600 # init (Stundenweise), alternativ 1800 oder 900 (halbe Stunde oder viertel Stunde)
			  limit = 3 # Limit (immer in Stunden, 0,5 = halbe Stunde, 0.25 = viertel Stunde)
			  range = limit * (3600/offset)
        changed = false
			  
			  course = Course.find(cID) # komplettes Objekt mit allen Feldern
			  size = Courselist.find_all_by_course_id(cID).count   # Größe des Kurses bestimmen
			  logger.debug "andere Zeit im selben Raum für Kurs #{course.id} (#{course.name})"
			  
			  time = getForCourse(course.id)[:startTime].utc
			  
			  logger.debug ""
			  logger.debug "#{@timeTableList.inspect}"
			  logger.debug ""
			  
			  range.times do |i|
			    newStartTime = time + offset
			    blockingTimeStart = Time.mktime(0, 1, 1, @startHour.to_i + 1, @startMin.to_i).utc
			    blockingTimeEnd = Time.mktime(0, 1 , 1, @endHour.to_i + 1, @endMin.to_i).utc
			    # den selben Raum nur prüfen, wenn es außerhalb des besetzten Zeitraums liegt
			    if !newStartTime.between?(blockingTimeStart, blockingTimeEnd)
  			    logger.debug "test #{newStartTime}"
  			    result = checkRoomAtOtherTime(course.id, newStartTime)
  			    if !result.nil? && result == 1
  			      changeTime(course.id, newStartTime)
  			      changed = true
  			      break
  	        end
  	        logger.debug "um #{newStartTime} passt es: #{result.nil? ? false.to_s : true.to_s}"
	        end
	        
			    if i % 2 == 0
			      offset *= -1 # alternating
			    else
			      offset *= -1 # alternating
			      offset += offset
		      end
		    end
			  
			  
			  if changed == false
			    @scheduleCCourses.push(cID)
		    end
			  
			end
			
			
		end # POST Aktion
	end # check Methode
	
	def show
	end

	def create
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
    def getCoursesToSchedule(roomID, weekday, startHour, startMin, endHour, endMin)
  		#setze Zeit zusammen
  		startTime = startHour + ":" + startMin
  		endTime = endHour + ":" + endMin
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
  				roomID, weekday, 
  				startTime, endTime, startTime, endTime,
  				startTime, startTime,
  				endTime, endTime
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
  	def checkFreeRoomAtSameTime(weekday, size, courseID, startDate, endDate, notRoom) 
  		#startTime = startDate.strftime("%H") + ":" + startDate.strftime("%M")
  	  #endTime = endDate.strftime("%H")  + ":" + endDate.strftime("%M") 
  		freeRoom = nil
  		
  		allRooms = Room.find(:all, :order => "size").map(&:id)
  		allRooms.each do |r|
  		  if r == notRoom
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
  			    @smallFreeRooms.push(Hash.[](
  			    :start, Time.mktime(0, 1, 1, startDate.strftime("%H").to_i + 1, startDate.strftime("%M").to_i).utc, 
  			    :end, Time.mktime(0, 1, 1, endDate.strftime("%H").to_i + 1, endDate.strftime("%M").to_i).utc, 
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
  einen Ersatzraum, der frei ist, außer notRoom (dieser ist nämlich gesperrt)
  Wenn ein Raum gefunden gib Raumnumme zurück, sonst -1
=end
  	def checkRoomAtOtherTime(courseID, startTime)
  	  oldStart = Course.find(courseID).start.utc
  	  oldEnd = Course.find(courseID).duration.utc
  	  duration = oldEnd - oldStart
  	  logger.debug "Kurs #{courseID} NEU: #{startTime} bis #{startTime + duration}"
  	  room = Course.find(courseID).room_id
  		freeTime = nil
      alreadyCourses = checkNewTimeAndRoom(room, startTime, startTime + duration)

      if alreadyCourses.empty?
        freeTime = 1
      end
      
      freeTime # return value
  	end

=begin
  Prüfe ob zu dem jeweiligen Zeitraum im jeweiligen Raum schon ein Kurs stattfindet
  auf Basis der Daten in @timeTableList
=end
  def checkNewTimeAndRoom(r, startDate, endDate)
    alreadyCourses = []
    @timeTableList.each do |l|
      #logger.debug "#{r.to_s} ==  #{l[:room].to_s}"
      if r == l[:room]  # Prüfe auf gleichen Raum
        #logger.debug "\tTRUE: #{r.to_s} ==  #{l[:room].to_s}"
        c1 = startDate - l[:startTime] < 0 && endDate - l[:startTime] > 0 # Start ist vorher, Ende liegt aber im/nach Zeitraum
        c2 = startDate - l[:endTime] < 0 && endDate - l[:endTime] > 0 # Start liegt im/vor Zeitraum, Ende außerhalb
        c3 = startDate.between?(l[:startTime], l[:endTime]) && endDate.between?(l[:startTime], l[:endTime]) # Start und Ende liegen innerhalb des Zeitraums
        logger.debug "\t\t Kurs: #{l[:course]} = #{l[:startTime].to_s} bis #{l[:endTime].to_s}"
        #logger.debug "\t\t\t c1: #{c1.to_s} - c2: #{c2.to_s} - c3: #{c3.to_s}"
        if c1 || c2 || c3
          alreadyCourses.push(l[:course])
        end
      end
    end # Schleife
    #logger.debug "1. Laenge: #{alreadyCourses.count}"
    alreadyCourses
  end

end
