class CoursesController < ApplicationController
  load_and_authorize_resource
  before_filter :load_general_course_data, only: [:show, :students, :edit]

  def create
    @course = Course.new(params[:course])
    @course.creator = current_user

    user_course = @course.user_courses.build()
    user_course.course = @course
    user_course.user = current_user
    user_course.role = Role.find_by_name(:lecturer)

    respond_to do |format|
      if @course.save  && user_course.save
        format.html { redirect_to edit_course_path(@course),
                      notice: "The course '#{@course.title}' has been created." }
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    if params[:course_atts]
      params[:course_atts].each do |id, val|
        ca = CourseThemeAttribute.find(id)
        ca.value = val
        ca.save
      end
    end
    respond_to do |format|
      if @course.update_attributes(params[:course])
        format.html { redirect_to edit_course_path(@course),
                      notice: 'Course setting has been updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def new
    respond_to do |format|
      format.html
    end
  end

  def edit
    # prepare the customizable attributes
    atts = []
    atts << ThemeAttribute.find_by_name('Background Color')
    atts << ThemeAttribute.find_by_name('Sidebar Link Color')
    atts << ThemeAttribute.find_by_name('Custom CSS')
    # atts << ThemeAttribute.find_by_name('Announcements Icon')
    # atts << ThemeAttribute.find_by_name('Missions Icon')
    # atts << ThemeAttribute.find_by_name('Trainings Icon')
    # atts << ThemeAttribute.find_by_name('Submissions Icon')
    # atts << ThemeAttribute.find_by_name('Leaderboard Icon')
    # atts << ThemeAttribute.find_by_name('Background Image')

    @course_atts = []
    atts.each do |att|
      @course_atts <<
        CourseThemeAttribute.where(course_id: @course.id, theme_attribute_id:att.id).first_or_create
    end
  end

  def show
    if can?(:participate, Course) || can?(:share, Course)
      @activities = @course.activities.order("created_at DESC")
      respond_to do |format|
        format.html
      end
    else
      respond_to do |format|
        format.html { render "courses/about" }
      end
    end
  end

  def destroy
    @course.destroy
    respond_to do |format|
      format.html { redirect_to courses_url }
      format.json { head :no_content }
    end
  end

  def students
    @lecturer_courses = []
    @student_courses = []
    uc_sorted = @course.user_courses.sort_by { |uc| uc.user.name }
    uc_sorted.each do |uc|
      if uc.is_student?
        @student_courses << uc
      elsif uc.is_lecturer?
        @lecturer_courses << uc
      end
    end
  end
end
