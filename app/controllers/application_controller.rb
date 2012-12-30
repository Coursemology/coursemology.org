class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    puts 'Access denied! Current user: ', current_user.to_json
    redirect_to access_denied_path, alert: exception.message
  end

  def current_uc
    if current_user and @course
      @current_uc ||= UserCourse.find_by_user_id_and_course_id(
        current_user.id,
        @course.id
      )
    end
    return @current_uc
  end

  def load_sidebar_data
    counts = {}
    if current_uc
      counts[:missions] = current_uc.get_unseen_missions.count
      counts[:announcements] = current_uc.get_unseen_announcements.count
      counts[:trainings] = current_uc.get_unseen_trainings.count
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
      text: "Students",
      url: course_students_url(@course),
      icon: "icon-user",
    }]

    if current_uc && current_uc.is_lecturer?
      nav_items << {
        text: "Enroll Requests",
        url: course_enroll_requests(@course),
        icon: "icon-bolt"
      }
    end
  end

  helper_method :current_uc
end
