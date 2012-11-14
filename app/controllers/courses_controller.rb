class CoursesController < ApplicationController
  load_and_authorize_resource

  def create
    @course = Course.new(params[:course])
    @course.creator = current_user

    user_course = @course.user_courses.build()
    user_course.course = @course
    user_course.user = current_user
    user_course.role = Role.find_by_name(:lecturer)

    respond_to do |format|
      if @course.save  && user_course.save
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
    @announcements = @course.announcements
    respond_to do |format|
      format.html
    end
  end

  def destroy
    @course.destroy
    respond_to do |format|
      format.html { redirect_to courses_url }
      format.json { head :no_content }
    end
  end
end
