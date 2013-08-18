class AchievementsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :achievement, through: :course

  before_filter :load_general_course_data, only: [:show, :index, :new, :edit]

  def index
    @achievements_with_info = []
    @achievements.each do |ach|
      req_check = {}
      if curr_user_course
        uach = UserAchievement.find_by_user_course_id_and_achievement_id(
          curr_user_course.id, ach.id)
        ach.requirements.each do |req|
          req_check[req.id] = req.satisfied?(curr_user_course)
        end
      end
      @achievements_with_info << {
        ach: ach,
        won: uach ? true : false,
        req_check: req_check
      }
    end
  end

  def fetch_data_for_form
    @all_ach = @course.achievements
    @all_asm = @course.asms
    @all_level = @course.levels
  end

  def new
    fetch_data_for_form
    @achievement.auto_assign = true
  end

  def edit
    fetch_data_for_form
  end

  def show
    @uach = UserAchievement.find_by_user_course_id_and_achievement_id(
        curr_user_course.id, @achievement.id)
  end

  def create
    @achievement.creator = current_user
    @achievement.update_requirement(params[:reqids], params[:new_reqs])
    respond_to do |format|
      if @achievement.save
        format.html { redirect_to course_achievements_url(@course),
                      notice: "The achievement '#{@achievement.title}' has been created." }
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    @achievement.update_requirement(params[:reqids], params[:new_reqs])
    respond_to do |format|
      if @achievement.update_attributes(params[:achievement])
        @course.user_courses.each do |user_course|
          if user_course.is_student?
            user_course.check_achievement(@achievement)
          end
        end
        format.html { redirect_to course_achievements_url(@course),
                      notice: "The achievement '#{@achievement.title}' has been updated." }
      else
        format.html { render action: "edit" }
      end
    end

  end

  def destroy
    @achievement.destroy
    respond_to do |format|
      format.html { redirect_to course_achievements_url(@course),
                    notice: "The achievement '#{@achievement.title}' has been removed." }
    end
  end
end
