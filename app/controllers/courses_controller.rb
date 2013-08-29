class CoursesController < ApplicationController
  load_and_authorize_resource
  before_filter :load_general_course_data, only: [:show, :students, :edit, :pending_gradings, :manage_students]


  def create
    @course = Course.new(params[:course])
    @course.creator = current_user
    @course.levels.build({ level: 0, exp_threshold: 0  })
    @course.save

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
    puts params
    if params[:user_course_id]
      uc = @course.user_courses.where(id:params[:user_course_id]).first
      uc.role_id = params[:role_id]
      uc.save
    end
    if params[:course_atts]
      params[:course_atts].each do |id, val|
        ca = CourseThemeAttribute.find(id)
        ca.value = val
        ca.save
      end
    end
    respond_to do |format|
      if params[:user_course_id]
        format.html { redirect_to course_staff_url(@course),
                                  notice: 'New staff added.'}
      elsif @course.update_attributes(params[:course])
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

      @announcement_pref = @course.home_announcement_pref
      if @announcement_pref.display?
        no_to_display = @course.home_announcement_no_pref.prefer_value.to_i
        @announcements = @course.announcements.accessible_by(current_ability).
            where("expiry_at > ?", Time.now).
            order("publish_at DESC").first(no_to_display)
        @is_new = {}
        if curr_user_course.id
          unseen = @announcements - curr_user_course.seen_announcements.first(no_to_display)
          unseen.each do |ann|
            @is_new[ann.id] = true
            curr_user_course.mark_as_seen(ann)
          end
        end
      end

      @activities_pref = @course.home_activities_pref
      if @activities_pref.display?
        @activities = @course.activities.order("created_at DESC").first(@course.home_activities_no_pref.prefer_value.to_i)
      end

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
    authorize! :destroy, @course
    @course.destroy
    respond_to do |format|
      format.html { redirect_to courses_url }
      format.json { head :no_content }
    end
  end

  def students
    @lecturer_courses = @course.user_courses.lecturer
    @student_courses = @course.user_courses.student.where(is_phantom: false)
    @ta_courses = @course.user_courses.tutor

    @std_paging = @course.students_paging_pref
    if @std_paging.display?
      @student_courses = Kaminari.paginate_array(@student_courses).page(params[:page]).per(@std_paging.prefer_value.to_i)
    end

  end

  def manage_students
    authorize! :manage, UserCourse
    if params[:phantom] && params[:phantom] == 'true'
      @phantom = true
    else
      @phantom = false
    end

    @student_courses = @course.user_courses.student.where(is_phantom: @phantom).order('lower(name)')
    if sort_column == 'tutor'
      puts "sort by tutor "
      @student_courses = @student_courses.sort_by {|uc| uc.tut_courses.first ? uc.tut_courses.first.id : 0  }
      if sort_direction == 'asc'
        @student_courses = @student_courses.reverse
      end
    end

    @staff_courses = @course.user_courses.staff
    @student_count = @student_courses.length

    @std_paging = @course.mgmt_std_paging_pref
    if @std_paging.display?
      @student_courses = Kaminari.paginate_array(@student_courses).page(params[:page]).per(@std_paging.prefer_value.to_i)
    end

  end

  def pending_gradings
    authorize! :see, :pending_gradings
    @pending_gradings = @course.get_pending_gradings(curr_user_course)
  end

end
