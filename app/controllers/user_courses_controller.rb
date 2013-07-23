class UserCoursesController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :user_course

  before_filter :load_general_course_data, only: [:show,:staff]

  def show
    @user_course.create_all_std_tags
    @std_tags = @user_course.std_tags.sort_by { |std_tag| std_tag.tag.tag_group_id || 0 }
  end

  def destroy
    @user_course.destroy
    respond_to do |format|
      format.html { render json: { status: 'OK' } }
    end
  end

  def update
    @user_course.role_id = params[:role_id]
    @user_course.user.name = params[:name]
    @user_course.tut_courses.map {|tc| tc.destroy }
    if @user_course.save && @user_course.user.save
      respond_to do |format|
        format.html { render json: { status: 'OK' }}
      end
    end
  end

  def staff
    @staff_courses = []
    @students_courses = []
    uc_sorted = @course.user_courses.sort_by { |uc| uc.user.name }
    uc_sorted.each do |uc|
      if uc.is_ta?
        @staff_courses << uc
      elsif uc.is_lecturer?
        @staff_courses << uc
      else
        @students_courses << uc
      end
    end
  end
end
