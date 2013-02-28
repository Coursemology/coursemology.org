class StatsController < ApplicationController
  load_and_authorize_resource :course
  before_filter :load_general_course_data

  def general
    @levels = @course.levels
  end

  def training
  end

  def mission
  end
end
