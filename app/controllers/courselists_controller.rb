class CourselistsController < ApplicationController
  # GET /courselists
  # GET /courselists.xml
  def index
    @courselists = Courselist.find(:all)
    
    if !params[:pupil].nil? && params[:pupil] != ""
      @courselists = Courselist.find_all_by_pupil_id(params[:pupil])
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @courselists }
    end
  end

  # GET /courselists/1
  # GET /courselists/1.xml
  def show
    @courselist = Courselist.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @courselist }
    end
  end

  # GET /courselists/new
  # GET /courselists/new.xml
  def new
    @courselist = Courselist.new
    @courses = Course.find(:all, :order => "weekday, teacher_id, start")
    @pupils = Pupil.find(:all, :order => :lastname)
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @courselist }
    end
  end
  
  def new_course_for_user
    @courselist = Courselist.new
    @pupil = Pupil.find(params['pupil'])
    @courses = Course.find(:all, :order => "weekday, teacher_id, start")
  end
  
  def new_pupil_for_course
    @courselist = Courselist.new
    @course = Course.find(params['course'])
    @pupils = Pupil.find(:all, :order => :lastname)
  end

  # GET /courselists/1/edit
  def edit
    @courselist = Courselist.find(params[:id])
  end

  # POST /courselists
  # POST /courselists.xml
  def create
    courseParams = params[:courselist]
    
    
    
    if params[:noRegister].to_i == 1 # noRegisteR == 1
      courseParams['register(1i)'] = "2000" # Jahr
      courseParams['register(2i)'] = "01" # Monat
      courseParams['register(3i)'] = "01" # Tag
    end
    
    if courseParams[:canceled].to_i == 0 # canceled == 0
      courseParams['quit(1i)'] = "1970" # Jahr
      courseParams['quit(2i)'] = "01" # Monat
      courseParams['quit(3i)'] = "01" # Tag
    end
    
    @courselist = Courselist.new(params[:courselist])
    @courselist.course_id = params[:course_id]
    @courselist.pupil_id = params[:pupil_id]
    
    respond_to do |format|
      if @courselist.save
        flash[:notice] = 'Courselist was successfully created.'
        format.html { redirect_to(@courselist) }
        format.xml  { render :xml => @courselist, :status => :created, :location => @courselist }
      else
        format.html { render :text => "<b>Fehler</b><br/>Sch&uuml;ler existiert wahrscheinlich schon." }
        #format.html { render :action => "new" }
        format.xml  { render :xml => @courselist.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /courselists/1
  # PUT /courselists/1.xml
  def update
    @courselist = Courselist.find(params[:id])

    respond_to do |format|
      if @courselist.update_attributes(params[:courselist])
        flash[:notice] = 'Courselist was successfully updated.'
        format.html { redirect_to(@courselist) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @courselist.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /courselists/1
  # DELETE /courselists/1.xml
  def destroy
    @courselist = Courselist.find(params[:id])
    @courselist.destroy

    respond_to do |format|
      format.html { redirect_to(courselists_url) }
      format.xml  { head :ok }
    end
  end
end
