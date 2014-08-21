class Tabs::TabsController < ApplicationController
  load_and_authorize_resource :course
  # GET /tab/tabs
  # GET /tab/tabs.json
  def index
    @tab_tabs = @course.tabs

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tab_tabs }
    end
  end

  # GET /tab/tabs/1
  # GET /tab/tabs/1.json
  def show
    @tab_tab = Tab.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tab_tab }
    end
  end

  # GET /tab/tabs/new
  # GET /tab/tabs/new.json
  def new
    @tab_tab = Tab::Tab.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tab_tab }
    end
  end

  # GET /tab/tabs/1/edit
  def edit
    @tab_tab = Tab.find(params[:id])
  end

  # POST /tab/tabs
  # POST /tab/tabs.json
  def create
    @tab = @course.tabs.build(JSON.parse(params[:tab]))
    if @course.tabs.count == 0
      if @tab.owner_type == Assessment::Training.to_s
        @course.trainings.each do |training|
          training.tab = @tab
          training.save
        end
      end
    end

    respond_to do |format|
      if @tab.save
        flash[:notice] =  "Tab #{@tab.title} was successfully created."
        format.json { render json: @tab, status: :created }
      else
        format.html { render action: "new" }
        format.json { render json: @tab.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tab/tabs/1
  # PUT /tab/tabs/1.json
  def update
    @tab_tab = Tab.find(params[:id])

    respond_to do |format|
      if @tab_tab.update_attributes(params[:tab])
        format.html { redirect_to @tab_tab, notice: 'Tab was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tab_tab.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tab/tabs/1
  # DELETE /tab/tabs/1.json
  def destroy
    @tab = Tab.find(params[:id])
    #put all trainings into first tab
    first_tab = @course.tabs.first
    first_tab = first_tab == @tab ? nil : first_tab
    @tab.trainings.each do |training|
      training.tab = first_tab
      training.save
    end
    @tab.destroy


    respond_to do |format|
      format.html { redirect_to tab_tabs_url }
      format.json { head :no_content }
    end
  end
end
