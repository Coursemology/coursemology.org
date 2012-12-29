class MissionsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :mission, through: :course, except: [:index]

  def index
    @missions = @course.missions.opened.still_open.order(:close_at) + @course.missions.closed
    if current_uc && current_uc.is_lecturer?
      @missions = @course.missions.future.order(:open_at) + @missions
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @missions }
    end
  end

  def show
    @questions = @mission.questions
    @question = Question.new
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @mission }
    end
  end

  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @mission }
    end
  end

  def edit
  end

  def create
    @mission.pos = @course.missions.size - 1
    @mission.creator = current_user
    respond_to do |format|
      if @mission.save
        format.html { redirect_to course_mission_url(@course, @mission),
                      notice: 'Mission was successfully created.' }
        format.json { render json: @mission, status: :created, location: @mission }
      else
        format.html { render action: "new" }
        format.json { render json: @mission.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @mission.update_attributes(params[:mission])
        format.html { redirect_to course_mission_url(@course, @mission),
                      notice: 'Mission was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @mission.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @mission.destroy

    respond_to do |format|
      format.html { redirect_to course_missions_url }
      format.json { head :no_content }
    end
  end
end
