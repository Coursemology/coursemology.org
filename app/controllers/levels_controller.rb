class LevelsController < ApplicationController
  load_and_authorize_resource :course
  load_resource :level, through: :course
  # load_and_authorize_resource :level, through: :course

  before_filter :load_sidebar_data, only: [:index]

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

  def create
    @level.level = @course.levels.size + 1
    @level.exp_threshold = params[:exp]
    if @level.save
      resp = render_to_string(
        partial: "levels/level_row",
        locals: { lvl: @level }
      )
      respond_to do |format|
        format.html { render text: resp }
      end
    end
  end

  def update
    @level.exp_threshold = params[:exp]
    if @level.save
      respond_to do |format|
        format.html { render json: { status: 'OK' } }
      end
    end
  end

  def destroy
    @level.destroy
    respond_to do |format|
      format.html { render json: { status: 'OK' } }
    end
  end
end
