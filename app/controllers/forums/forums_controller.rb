class Forums::ForumsController < ApplicationController
  load_and_authorize_resource :course

  before_filter :load_general_course_data, except: [:destroy]

  def index
    @forums = @course.forums
  end
end
