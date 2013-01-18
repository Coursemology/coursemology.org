class MissionsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :mission, through: :course, except: [:index]
  before_filter :load_general_course_data, only: [:show, :index, :new, :edit]

  def index
    @is_new = {}
    if curr_user_course.id
      @missions = curr_user_course.get_missions
      unseen = curr_user_course.get_unseen_missions
      unseen.each do |um|
        @is_new[um.id] = true
        curr_user_course.mark_as_seen(um)
      end
    else
      @missions = @course.missions.opened.still_open.order(:close_at) + @course.missions.closed
    end
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def show
    @questions = @mission.questions
    @question = Question.new
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def new
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
  end

  def create
    @mission.pos = @course.missions.count - 1
    @mission.creator = current_user
    respond_to do |format|
      if @mission.save
        format.html { redirect_to course_mission_url(@course, @mission),
                      notice: 'Mission was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    respond_to do |format|
      if @mission.update_attributes(params[:mission])
        format.html { redirect_to course_mission_url(@course, @mission),
                      notice: 'Mission was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @mission.destroy
    respond_to do |format|
      format.html { redirect_to course_missions_url }
    end
  end
end
