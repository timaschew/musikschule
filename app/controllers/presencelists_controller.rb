class PresencelistsController < ApplicationController
  before_filter :login_required
  
  # GET /presencelists
  # GET /presencelists.xml
  def index
    @presencelists = Presencelist.all
    
    if logged_in?
      @firstname = current_user.firstname
      @lastname = current_user.lastname
      @id = current_user.id
      
      @courses = Course.find_all_by_teacher_id(6)
      
    end
    #else : login form, automatic redirection, when user is not logged in (before_filter)
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @presencelists }
    end
    

    
  end
  
  
  #t.integer :course_id
  #t.integer :pupil_id
  #t.date :date
  #t.integer :status
  #t.text :comment
  
  def generate
    
    @course = 2
    @startDate = "2009-06-08"
    @endDate = "2009-06-08"
    @datePrefix = "2009-06-"
    @days = ["08", "15", "22", "29"]
    @foundList = Courselist.find_all_by_course_id(2)
    @pupils = @foundList.map(&:pupil_id)

    
    
  end

  # GET /presencelists/1
  # GET /presencelists/1.xml
  def show
    @presencelist = Presencelist.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @presencelist }
    end
  end

  # GET /presencelists/new
  # GET /presencelists/new.xml
  def new
    @presencelist = Presencelist.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @presencelist }
    end
  end

  # GET /presencelists/1/edit
  def edit
    @presencelist = Presencelist.find(params[:id])
  end

  # POST /presencelists
  # POST /presencelists.xml
  def create
    @presencelist = Presencelist.new(params[:presencelist])

    respond_to do |format|
      if @presencelist.save
        flash[:notice] = 'Presencelist was successfully created.'
        format.html { redirect_to(@presencelist) }
        format.xml  { render :xml => @presencelist, :status => :created, :location => @presencelist }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @presencelist.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /presencelists/1
  # PUT /presencelists/1.xml
  def update
    @presencelist = Presencelist.find(params[:id])

    respond_to do |format|
      if @presencelist.update_attributes(params[:presencelist])
        flash[:notice] = 'Presencelist was successfully updated.'
        format.html { redirect_to(@presencelist) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @presencelist.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /presencelists/1
  # DELETE /presencelists/1.xml
  def destroy
    @presencelist = Presencelist.find(params[:id])
    @presencelist.destroy

    respond_to do |format|
      format.html { redirect_to(presencelists_url) }
      format.xml  { head :ok }
    end
  end
  
end
