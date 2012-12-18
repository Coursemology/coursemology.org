class LevelsController < ApplicationController
  load_and_authorize_resource :course
  load_resource :level, through: :course
  # load_and_authorize_resource :level, through: :course

  def index
  end

  def populate
    if @course.levels.size == 0 && params[:num_level]
      num_level = params[:num_level]
      num_level.to_i.times do |i|
        lvl = i + 1
        @course.levels.build({
          level: lvl,
          exp_threshold: lvl * lvl * 1000
        })
      end
      @course.save
    end
    respond_to do |format|
      format.html { redirect_to course_levels_path(@course) }
    end
  end

  def show
  end
end
