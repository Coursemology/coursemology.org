class UserCoursesController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :user_course

  before_filter :load_general_course_data, only: [:show,:stuff]

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
    if @user_course.save
      respond_to do |format|
        format.html { render json: { status: 'OK' }}
      end
    end
  end

  def stuff
    @stuff_course = []
    @students_course = []
    uc_sorted = @course.user_courses.sort_by { |uc| uc.user.name }
    uc_sorted.each do |uc|
      if uc.is_ta?
        @stuff_course << uc
      elsif uc.is_lecturer?
        @stuff_course << uc
      else
        @students_course << uc
      end
    end
  end
end
