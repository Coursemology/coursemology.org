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
    @tab_tab = Tab::Tab.find(params[:id])

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
    @tab_tab = Tab::Tab.find(params[:id])
  end

  # POST /tab/tabs
  # POST /tab/tabs.json
  def create
    @tab = @course.tabs.build({title: params[:title], description: params[:description], owner_type: params[:type]})

    if @course.tabs.count == 0
      if params[:type] == Training.to_s
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
    @tab_tab = Tab::Tab.find(params[:id])

    respond_to do |format|
      if @tab_tab.update_attributes(params[:tab_tab])
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
    @tab_tab = Tab::Tab.find(params[:id])
    @tab_tab.destroy

    respond_to do |format|
      format.html { redirect_to tab_tabs_url }
      format.json { head :no_content }
    end
  end
end
