class TestingController < ApplicationController
  
  def index
    
    @schedule_actions = ScheduleAction.all
    @schedules = Schedule.all
    @small_rooms = SmallRoom.all
    
  end
  
  def show
    
    @schedule_action = ScheduleAction.find(params[:id])
    @schedules = @schedule_action.schedules
    @small_rooms = @schedule_action.get_small_rooms
    
  end
  
  def test_session
    # if no session is set or the data is deleted from db, generate new Action and set new session
    if session[:schedule].nil? || ScheduleAction.find(:all, :conditions => {:id => session[:schedule]}).empty?
      action = ScheduleAction.new
      action.save
      session[:schedule] = action.id
      render :text => "Neue Session: Schedule ID = #{action.id} == #{session[:schedule]}"
    else
      # show session
      render :text => "Session: Schedule ID = #{session[:schedule]}"
    end
  end
  
  def test_time1
    c = Course.new
    zeit = Time.local(0,1,1,14,33)
    c.start = zeit
    c.save
    
    r = Course.last
    time = r.start
    render :text => "Zeit: #{time} war aber #{zeit}"
    
  end
  
  def test_time2

    r = Course.first
    time = r.start
    render :text => "Zeit: #{time}"
    
  end
  
  
end