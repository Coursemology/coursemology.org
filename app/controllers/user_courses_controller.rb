class UserCoursesController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :user_course

  before_filter :load_general_course_data, only: [:show,:staff, :achievements]

  def show
    @tag_groups = @course.tag_groups.includes(:tags)
    uc = @course.tag_groups.uncategorized
    @tag_groups -= [uc]
    @tag_groups << uc
  end

  def destroy
    @user_course.destroy
    respond_to do |format|
      format.json { render json: { status: 'OK' } }
      format.html { redirect_to course_students_path(@course) }
    end
  end


  def update
    if params[:role_id]
      @user_course.role_id = params[:role_id]
    end
    if params[:name]
      @user_course.user.name = params[:name].strip
    end
    if params[:email]
      @user_course.user.email = params[:email].strip
    end

    @user_course.is_phantom =  params[:is_phantom] || false

    tut_group_assign

    respond_to do |format|
      if @user_course.save && @user_course.user.save
        format.json { render json: { status: 'OK' }}
        format.html { redirect_to params[:redirect_back_url], notice: 'Updated successfully.' }
      else
        format.json { render json: {errors: @user_course.user.errors}}
        flash[:error] ='Update failed. You may entered invalid name or email.'
        format.html { redirect_to params[:redirect_back_url] }
      end
    end
  end

  def staff
    @staff_courses = []
    @students_courses = []
    uc_sorted = @course.user_courses.order('lower(name)')
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

  def remove_staff
    @user_course.role = Role.student.first
    @user_course.save
    respond_to do |format|
      format.json { render json: { status: 'OK' } }
      format.html { redirect_to course_students_path(@course) }
    end
  end

  private

  def tut_group_assign
    #invalid
    unless params[:tutor]
      return
    end
    #didn't change
    if @user_course.get_my_tutors.first and (@user_course.get_my_tutors.first.id == params[:tutor].first.to_i)
      return
    end

    #updated
    @user_course.tut_group_courses.map {|tc| tc.destroy }

    #unassigned to assigned
    if params[:tutor].first.to_i > 0
      tg = @course.tutorial_groups.build
      tg.std_course = @user_course
      tg.tut_course_id =  params[:tutor].first
      tg.save
    else

    end
  end
end
