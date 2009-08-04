class TimetablesController < ApplicationController
  def index
    @rooms = Room.all
  end
  
  def show
    @room = Room.find(params[:id])
  end
  
  def times
    @allRooms = Room.find(:all)
    
    @weekday = params[:day]
    if @weekday.nil? || @weekday == ""
      @weekday = 1
    end
    
    @courseList = {}
    @courseTimes = {}
    @courseRooms = {}
    
    #Zeitdauer eines Unterrichtstages ist im application_controller definiert
    time = $TIMETABLESTART
    $TIMETABLEEND.times do 
      @allRooms.each do |r|
        tmp = Course.find(:all, :conditions => "start like '%#{time}%' AND weekday = #{@weekday} AND room_id = #{r.id}").map(&:id)[0]
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
    
    
    
    
  end
  
end
