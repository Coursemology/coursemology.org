class LevelsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :level, through: :course

  before_filter :load_general_course_data, only: [:index, :show, :chronology]

  def index
    @tab = 'Levels'
  end

  def chronology
    @tab = 'Chronology'
    @asms = @course.assessments.includes(:tab)
  end

  def show
  end

  def populate
    if @course.levels.count <= 1 && params[:num_level]
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
      format.html { redirect_to course_levels_path(@course),
                                notice: "#{params[:num_level]} levels has been generated!"}
    end
  end

  def mass_update
    exp_levels = params[:exps].map(&:to_i).select { |num| num > 0 }
    new_level_count = exp_levels.count

    # delete extra levels
    @course.levels.each do |lvl|
      if lvl.level > new_level_count
        lvl.destroy
      end
    end

    # always have 1 level: level 0
    if @course.levels.count == 0 || @course.levels.first.level != 0
      @course.levels.build(level: 0, exp_threshold: 0)
      @course.save
    end

    # create new levels if necessary
    curr_level_count = @course.levels.count
    if curr_level_count <= new_level_count
      (curr_level_count..new_level_count).each do |level|
        @course.levels.build(level: level)
      end
    end
    @course.save

    # update exp threshold
    @course.levels.each do |lvl|
      # avoid accessing deleted levels
      if lvl.level <= new_level_count && lvl.level > 0
        lvl.exp_threshold = exp_levels[lvl.level-1]
        lvl.save
      end
    end

    # update students level
    Thread.new {
      @course.user_courses.each { |uc| uc.update_exp_and_level }
    }

    redirect_to course_levels_path(@course), notice: "Levels updated!"
  end
end
