class CoursesController < ApplicationController
  # GET /courses
  # GET /courses.xml
  def index
    
    sorting = Hash.new("weekday, teacher_id, start") # standard
    sorting["id"] = "id"
    sorting["teacher"] = "teacher_id, weekday, start"
    sorting["day"] = "weekday, start, teacher_id"
    sorting["subject"] = "subject_id, weekday, start"
    sorting["room"] = "room_id, weekday, start"
    sorting["start"] = "start, weekday"
    sorting["stop"] = "duration, weekday"
    sorting["name"] = "name"
     
    @courses = Course.find(:all, :order => sorting[params[:sort]])


    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @courses }
    end
  end

  # GET /courses/1
  # GET /courses/1.xml
  def show
    @course = Course.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @course }
    end
  end

  # GET /courses/new
  # GET /courses/new.xml
  def new
    
    @hour = 14
    @min = 0
    @weekday = 1
    @room = 1
    @hour = params[:time][0,2] unless params[:time].blank?
    @min = params[:time][2,2] unless params[:time].blank?
    @weekday = params[:day].to_i unless params[:day].blank?
    @room = params[:room].to_i unless params[:room].blank?
    
    @course = Course.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @course }
    end
  end

  # GET /courses/1/edit
  def edit
    @course = Course.find(params[:id])
  end

  # POST /courses
  # POST /courses.xml
  def create
    @course = Course.new(params[:course])

    respond_to do |format|
      if @course.save
        flash[:notice] = 'Course was successfully created.'
        format.html { redirect_to(@course) }
        format.xml  { render :xml => @course, :status => :created, :location => @course }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /courses/1
  # PUT /courses/1.xml
  def update
    @course = Course.find(params[:id])

    respond_to do |format|
      if @course.update_attributes(params[:course])
        flash[:notice] = 'Course was successfully updated.'
        format.html { redirect_to(@course) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @course.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1
  # DELETE /courses/1.xml
  def destroy
    @course = Course.find(params[:id])
    @course.destroy

    respond_to do |format|
      format.html { redirect_to(courses_url) }
      format.xml  { head :ok }
    end
  end
end
