class CoursesController < ApplicationController
  load_and_authorize_resource
  before_filter :load_general_course_data, only: [:show, :students, :edit, :pending_gradings, :manage_students]

  def index
    @courses = Course.online_course
  end

  def create
    @course = Course.new(params[:course])
    @course.creator = current_user
    @course.levels.build({ level: 0, exp_threshold: 0  })

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

  respond_to :html, :json
  def update
    message = nil
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
    if params[:course]
      if params[:course][:is_publish] || params[:course][:is_open]
        is_publish = params[:course][:is_publish].to_i == 1 ? true : false
        is_open = params[:course][:is_open].to_i == 1 ? true : false
        if is_publish != @course.is_publish? || is_open != @course.is_open?
          authorize! :manage, :course_admin
        end
      end
    end

    if params[:course_owner]
      user = User.where(id: params[:course_owner]).first
      @course.creator = user
      @course.is_publish = params[:is_publish] == 'true'
      @course.save
    end
    respond_to do |format|
      if params[:user_course_id]
        format.html { redirect_to course_staff_url(@course),
                                  notice: 'New staff added.'}
      elsif params[:course_owner]
        format.json {render json:  {course:@course, owner: @course.creator.name } }
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

      unless curr_user_course.new_record?
        curr_user_course.update_attribute(:last_active_time, Time.now)
      end
      @announcement_pref = @course.home_announcement_pref
      if @announcement_pref.display?
        no_to_display = @course.home_announcement_no_pref.prefer_value.to_i
        @announcements = @course.announcements.accessible_by(current_ability).
            where("expiry_at > ?", Time.now).
            order("publish_at DESC").first(no_to_display)
        @is_new = {}
        if curr_user_course.id
          unseen = @announcements - curr_user_course.seen_announcements
          unseen.each do |ann|
            @is_new[ann.id] = true
            curr_user_course.mark_as_seen(ann)
          end
        end
      end

      @activities_pref = @course.home_activities_pref
      # if @activities_pref.display?
      #   @activities = @course.activities.order("created_at DESC").first(@course.home_activities_no_pref.prefer_value.to_i)
      # end

      @pending_actions = curr_user_course.pending_actions.to_show.
          select { |pa| pa.item.publish? && pa.item.open_at < Time.now }.
          sort_by {|pa| pa.item.close_at || Time.now }

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
    title = @course.title
    @course.is_pending_deletion = true
    @course.save
    #@course.destroy
    @course.lect_courses.each do |uc|
      UserMailer.delay.course_deleted(@course.title, uc.user)
    end
    Delayed::Job.enqueue(BackgroundJob.new(@course.id, "DeleteCourse"))
    respond_to do |format|
      flash[:notice] = "The course '#{title}' is pending for deletion."
      redirect_url = params[:origin] || courses_url
      format.html { redirect_to redirect_url }
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
