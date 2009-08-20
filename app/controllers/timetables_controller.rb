class TimetablesController < ApplicationController
  
  #ActiveRecord::Base.logger = Logger.new("log/schedules_controller.log") 
  #ActiveRecord::Base.logger.level = 1 # warn
  ActiveRecord::Base.logger = Logger.new(STDOUT) 
  ActiveRecord::Base.logger.level = 0 # warn
  def index
    @rooms = Room.all
  end
  
  def show_room
    @room = Room.find(params[:id])
  end
  
  def show_day
    @allRooms = Room.find(:all)
    @weekday = 1
    @weekday = params[:day] unless params[:day] == ""
    @weekday_string = Time.mktime(0,5,@weekday.to_i).strftime("%A")
    
  end
  
end
