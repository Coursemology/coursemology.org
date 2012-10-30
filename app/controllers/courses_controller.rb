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

  def update
    respond_to do |format|
      if @course.update_attributes(params[:course])
        format.html { redirect_to @course, notice: 'Course was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  def new
    respond_to do |format|
      format.html
    end
  end

  def edit
  end

  def show
    @assignments = @course.assignments
    respond_to do |format|
      format.html
    end
  end
end
