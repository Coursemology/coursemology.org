class AchievementsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :achievement, through: :course

  def index
    # need to know for each achievement:
    # - student has won it or not?
    # - what requirements has the students fulfilled
    uc = UserCourse.find_by_user_id_and_course_id(
      current_user.id, @course.id)

    @achievements_with_info = []

    @achievements.each do |ach|
      uach = UserAchievement.find_by_user_course_id_and_achievement_id(
        uc.id, ach.id)
      req_check = {}
      ach.requirements.each do |req|
        req_check[req.id] = uach || req.satisfied?(uc)
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
  end

  def edit
    fetch_data_for_form
  end

  def show
  end

  def update_requirement(ach, reqids)
    if reqids
      reqids.each do |reqid|
        req = Requirement.find(reqid.to_i)
        req.obj = ach
        req.save
        puts req.to_json
      end
    end
  end

  def create
    @achievement.creator = current_user
    respond_to do |format|
      if @achievement.save
        update_requirement(@achievement, params[:reqids])
        format.html { redirect_to course_achievements_url(@course),
                      notice: 'achievement was successfully created.' }
        format.json { render json: @achievement, status: :created, location: @achievement }
      else
        format.html { render action: "new" }
        format.json { render json: @achievement.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    update_requirement(@achievement, params[:reqids])
    respond_to do |format|
      if @achievement.update_attributes(params[:achievement])
        # should render single achievement view?? yeah should. with students who has won the achievement
        format.html { redirect_to course_achievement_url(@course),
                      notice: 'achievement was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @achievement.errors, status: :unprocessable_entity }
      end
    end

  end

  def destroy
    @achievement.destroy
    respond_to do |format|
      format.html { redirect_to course_achievements_url(@course) }
    end
  end
end
