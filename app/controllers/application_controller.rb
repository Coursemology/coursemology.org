class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    puts 'Access denied! Current user: ', current_user.to_json
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
      icon: "icon-bullhorn",
      count: counts[:announcements] || 0
    }, {
      text: "Missions",
      url: course_missions_url(@course),
      icon: "icon-envelope",
      count: counts[:missions] || 0
    }, {
      text: "Trainings",
      url: course_trainings_url(@course),
      icon: "icon-envelope",
      count: counts[:trainings] || 0
    }, {
      text: "Submissions",
      url: course_submissions_url(@course),
      icon: "icon-envelope-alt",
      count: counts[:submissions] || 0
    }, {
      text: "Achievements",
      url: course_achievements_url(@course),
      icon: "icon-star",
      count: counts[:achievements_url] || 0
    }, {
      text: "Leaderboards",
      url: course_leaderboards_url(@course),
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
    load_sidebar_data
    load_popup_notifications
  end

  helper_method :curr_user_course
end
