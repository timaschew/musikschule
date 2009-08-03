class TimetablesController < ApplicationController
  def index
    @rooms = Room.all
  end
  
  def show
    @room = Room.find(params[:id])
  end
  
  def times
    @allRooms = Room.find(:all)
    
    @weekdayNo = params[:day]
    @roomID = params[:room]
    @allScheduledRooms = params[:allScheduledRooms]
    @allParallelCourses = params[:allParallelCourses]
    
    @courseList = {}
    @courseTimes = {}
    @courseRooms = {}
    
    time = 9
    11.times do 
      @allRooms.each do |r|
        tmp = Course.find(:all, :conditions => "start like '%#{time}%' AND weekday = #{@weekdayNo} AND room_id = #{r.id}").map(&:id)[0]
        @courseList[time.to_s + "-" + r.id.to_s] = tmp
        @courseRooms[r.id.to_s] = tmp
      end
      @courseTimes[time.to_s] = @courseRooms
      @courseRooms = {}
      time += 1
    end
    #puts "INSPECT: #{@courseTimes.inspect}"
    
    @freeRooms = params[:freeRooms]
    @isScheduled = 0
    
    if !@freeRooms.nil? && !@freeRooms.empty?
      @isScheduled = 1
    end
    
    puts "INSPECT:1 #{@allScheduledRooms.inspect}"
    puts "INSPECT:2 #{@allParallelCourses.inspect}"
    
    
    
  end
  
  def scheduledTime
    @weekday = params[:day]
    @startTimeM = params[:startM]
    @startTimeH = params[:startH]
    @endTimeM = params[:endM]
    @endTimeH = params[:endH]
    @courses = params[:courses]
    
  end
  
end
