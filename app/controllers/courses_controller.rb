class CoursesController < ApplicationController
  load_and_authorize_resource

  def create
    @course = Course.new(params[:course])
    @course.creator = current_user

    respond_to do |format|
      if @course.save 
        format.html { redirect_to @course, notice: "Course was successfully created." }
      else
        format.html { render action: "new" }
      end
    end
  end

  def new
    respond_to do |format|
      format.html
    end
  end

  def show
    puts params
    respond_to do |format|
      format.html
    end
  end
end
