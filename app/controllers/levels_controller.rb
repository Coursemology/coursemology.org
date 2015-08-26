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

    # Update existing levels
    existing_levels = @course.levels.select { |l| l.level > 0 }
    existing_levels.each_with_index do |level, index|
      if exp_levels.any?
        level.exp_threshold = exp_levels.shift
        level.level =  index + 1
        level.save
      else
        level.destroy
      end
    end

    # Create new levels
    max_level = @course.levels.pluck(:level).max
    exp_levels.each do |exp|
      @course.levels.build(level: max_level + 1, exp_threshold: exp)
      max_level += 1
    end

    # always have 1 level: level 0
    if @course.levels.first.try(:level) != 0
      @course.levels.build(level: 0, exp_threshold: 0)
    end
    @course.save

    # update students level
    Thread.new {
      @course.user_courses.each { |uc| uc.update_exp_and_level }
    }

    redirect_to course_levels_path(@course), notice: "Levels updated!"
  end
end
