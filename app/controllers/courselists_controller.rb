class CourselistsController < ApplicationController
  # GET /courselists
  # GET /courselists.xml
  def index
    @courselists = Courselist.all

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

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @courselist }
    end
  end

  # GET /courselists/1/edit
  def edit
    @courselist = Courselist.find(params[:id])
  end

  # POST /courselists
  # POST /courselists.xml
  def create
    @courselist = Courselist.new(params[:courselist])

    respond_to do |format|
      if @courselist.save
        flash[:notice] = 'Courselist was successfully created.'
        format.html { redirect_to(@courselist) }
        format.xml  { render :xml => @courselist, :status => :created, :location => @courselist }
      else
        format.html { render :action => "new" }
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
