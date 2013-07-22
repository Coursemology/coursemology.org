class MissionsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :mission, through: :course
  before_filter :load_general_course_data, only: [:show, :index, :new, :edit]

  def index
    @is_new = {}
    @missions = @course.missions.accessible_by(current_ability)
                  .order(:open_at).reverse_order
                  .page(params[:page])
    if curr_user_course.id
      unseen = @missions - curr_user_course.seen_missions
      unseen.each do |um|
        @is_new[um.id] = true
        curr_user_course.mark_as_seen(um)
      end
    end
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def show
    @questions = @mission.questions
    @question = Question.new
    @question.max_grade = 10
    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def new
    @mission.exp = 1000
    @mission.open_at = DateTime.now.beginning_of_day
    @mission.close_at = DateTime.now.end_of_day + 7  # 1 week from now

    @tags = @course.tags
    @asm_tags = {}

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    @tags = @course.tags
    @asm_tags = {}
    @mission.asm_tags.each { |asm_tag| @asm_tags[asm_tag.tag_id] = true }
  end

  def create
    puts "params",params
    @mission.pos = @course.missions.count - 1
    @mission.creator = current_user
    @mission.update_tags(params[:tags])
    puts "mission_saving",@mission
    if params[:files]
      @mission.attach_files(params[:files].values)
    end
    respond_to do |format|
      if @mission.save
        format.html { redirect_to new_course_mission_question_path(@course, @mission),
                      notice: "The mission #{@mission.title} has been created." }
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    @mission.update_tags(params[:tags])
    if params[:files]
      @mission.attach_files(params[:files].values)
    end
    respond_to do |format|
      if @mission.update_attributes(params[:mission])
        format.html { redirect_to course_mission_url(@course, @mission),
                      notice: "The mission #{@mission.title} has been updated." }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @mission.destroy
    respond_to do |format|
      format.html { redirect_to course_missions_url,
                    notice: "The mission #{@mission.title} has been removed." }
    end
  end
end
