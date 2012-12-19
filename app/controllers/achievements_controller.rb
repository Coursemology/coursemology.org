class AchievementsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :achievement, through: :course

  def index
  end

  def new
  end

  def show
  end

  def create
    @achievement.creator = current_user
    respond_to do |format|
      if @achievement.save
        format.html { redirect_to course_achievement_url(@course),
                      notice: 'achievement was successfully created.' }
        format.json { render json: @achievement, status: :created, location: @achievement }
      else
        format.html { render action: "new" }
        format.json { render json: @achievement.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
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

    format.html { redirect_to action: :index }
  end
end
