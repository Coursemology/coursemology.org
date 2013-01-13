class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
    redirect_to access_denied_path, alert: exception.message
  end

  def curr_user_course
    if current_user and @course
      @curr_user_course ||= UserCourse.find_by_user_id_and_course_id(
        current_user.id,
        @course.id
      )
    end
    return @curr_user_course
  end

  def load_theme_setting
    atts = []
    atts << ThemeAttribute.find_by_name('Background Color')
    atts << ThemeAttribute.find_by_name('Sidebar Link Color')
    atts << ThemeAttribute.find_by_name('Announcements Icon')
    atts << ThemeAttribute.find_by_name('Missions Icon')
    atts << ThemeAttribute.find_by_name('Trainings Icon')
    atts << ThemeAttribute.find_by_name('Submissions Icon')
    atts << ThemeAttribute.find_by_name('Leaderboard Icon')
    atts << ThemeAttribute.find_by_name('Background Image')

    @theme_settings = {}
    atts.each do |att|
      ca = CourseThemeAttribute.where(course_id: @course.id, theme_attribute_id:att.id).first_or_create
      @theme_settings[att.name] = ca.value
    end
    puts @theme_settings.to_json

  end

  def load_sidebar_data
    counts = {}
    if curr_user_course
      counts[:missions] = curr_user_course.get_unseen_missions.count
      counts[:announcements] = curr_user_course.get_unseen_announcements.count
      counts[:trainings] = curr_user_course.get_unseen_trainings.count
      if curr_user_course.is_lecturer?
        # lecturers see number of new submissions of all students in the course
        counts[:submissions] = curr_user_course.get_unseen_sbms.count
      end
      # students see the number of new gradings
    end
    # in the future, nav items can be loaded from the database
    @nav_items = []
    # home
    @nav_items = [ {
      text: "Home",
      url: course_path(@course),
      icon: "icon-home"
    }, {
      text: "Announcements",
      url: course_announcements_url(@course),
      img: @theme_settings["Announcements Icon"],
      icon: "icon-bullhorn",
      count: counts[:announcements] || 0
    }, {
      text: "Missions",
      url: course_missions_url(@course),
      img: @theme_settings["Missions Icon"],
      icon: "icon-envelope",
      count: counts[:missions] || 0
    }, {
      text: "Trainings",
      url: course_trainings_url(@course),
      img: @theme_settings["Trainings Icon"],
      icon: "icon-envelope",
      count: counts[:trainings] || 0
    }, {
      text: "Submissions",
      url: course_submissions_url(@course),
      img: @theme_settings["Submissions Icon"],
      icon: "icon-envelope-alt",
      count: counts[:submissions] || 0
    }, {
      text: "Leaderboards",
      url: course_leaderboards_url(@course),
      img: @theme_settings["Leaderboard Icon"],
      icon: "icon-star-empty"
    }, {
      text: "Students",
      url: course_students_url(@course),
      icon: "icon-user",
    }]

    if curr_user_course && curr_user_course.is_lecturer?
      @nav_items << {
        text: "Enroll Requests",
        url: course_enroll_requests_url(@course),
        icon: "icon-bolt"
      }

      @nav_items << {
        text: "Settings",
        url: edit_course_url(@course),
        icon: "icon-cog"
      }
    end
  end

  def load_popup_notifications
    if curr_user_course
      # for now all notifications are popup
      @popup_notifications = curr_user_course.get_unseen_notifications
      @popup_notifications.each do |popup|
        curr_user_course.mark_as_seen(popup)
      end
    end
  end

  def load_general_course_data
    if @course
      load_theme_setting
      load_sidebar_data
      load_popup_notifications
    end
  end

  private
  def current_ability
    if @course
      @current_ability ||= CourseAbility.new(curr_user_course)
    else
      @current_ability ||= Ability.new(current_user)
    end
  end

  helper_method :curr_user_course
end
