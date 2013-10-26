class LessonPlanController < ApplicationController
  load_and_authorize_resource :course
  #load_and_authorize_resource :lesson_plan_entry, through: :course

  before_filter :load_general_course_data
  
  def index
    
  end
end
