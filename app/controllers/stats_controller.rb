class StatsController < ApplicationController
  load_and_authorize_resource :course
  before_filter :load_general_course_data

  def general
    @missions = @course.missions
    @trainings = @course.trainings
    @levels = @course.levels
    @achievements = @course.achievements
  end

  def mission
    @mission = Mission.find(params[:mission_id])
    authorize! :view_stat, @mission
  end

  def training
    @training = Training.find(params[:training_id])
    authorize! :view_stat, @training
  end
end
