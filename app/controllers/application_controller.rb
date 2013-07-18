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
    @curr_user_course ||= UserCourse.new
    return @curr_user_course
  end

  def load_theme_setting
    atts = []
    atts << ThemeAttribute.find_by_name('Background Color')
    atts << ThemeAttribute.find_by_name('Sidebar Link Color')
    atts << ThemeAttribute.find_by_name('Custom CSS')
    # atts << ThemeAttribute.find_by_name('Announcements Icon')
    # atts << ThemeAttribute.find_by_name('Missions Icon')
    # atts << ThemeAttribute.find_by_name('Trainings Icon')
    # atts << ThemeAttribute.find_by_name('Submissions Icon')
    # atts << ThemeAttribute.find_by_name('Leaderboards Icon')
    # atts << ThemeAttribute.find_by_name('Background Image')

    @theme_settings = {}
    atts.each do |att|
      ca = CourseThemeAttribute.where(course_id: @course.id, theme_attribute_id:att.id).first_or_create
      @theme_settings[att.name] = ca.value
    end

    theme = @course.course_themes.first
    if theme
      theme_folder = theme.theme_folder_url
      @theme_settings['Announcements Icon'] = File.exist?("#{theme_folder}/images/announcements_icon.png") ? "#{theme_folder}/images/announcements_icon.png" : nil
      @theme_settings['Trainings Icon'] = File.exist?("#{theme_folder}/images/trainings_icon.png") ? "#{theme_folder}/images/trainings_icon.png" : nil
      @theme_settings['Submissions Icon'] =  File.exist?("#{theme_folder}/images/submissions_icon.png") ? "#{theme_folder}/images/submissions_icon.png" : nil
      @theme_settings['Leaderboards Icon'] = File.exist?("#{theme_folder}/images/leaderboards_icon.png") ? "#{theme_folder}/images/leaderboards_icon.png" : nil
      @theme_settings['Background Image'] = File.exist?("#{theme_folder}/images/background.png") ? "#{theme_folder}/images/background.png" : nil
    end
  end

  def load_sidebar_data
    counts = {}
    if curr_user_course.id
      all_trainings = @course.trainings.accessible_by(current_ability)
      unseen_trainings = all_trainings - curr_user_course.seen_trainings
      counts[:trainings] = unseen_trainings.count

      all_announcements = @course.announcements.accessible_by(current_ability)
      unseen_anns = all_announcements - curr_user_course.seen_announcements
      counts[:announcements] = unseen_anns.count

      all_missions = @course.missions.accessible_by(current_ability)
      unseen_missions = all_missions - curr_user_course.seen_missions
      counts[:missions] = unseen_missions.count
      if can? :see_all, Submission
        # lecturers see number of new submissions of all students in the course
        all_sbms = @course.submissions.accessible_by(current_ability) +
                @course.training_submissions.accessible_by(current_ability) +
                @course.quiz_submissions.accessible_by(current_ability)
        unseen_sbms = all_sbms - curr_user_course.get_seen_sbms
        counts[:submissions] = unseen_sbms.count
      end
      # TODO students see the number of new gradings
    end
    # in the future, nav items can be loaded from the database
    @nav_items = []
    # home
    @nav_items = [{
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
      text: "Levels",
      url: course_levels_url(@course),
      icon: "icon-star-empty"
    }, {
      text: "Achievements",
      url: course_achievements_url(@course),
      icon: "icon-star"
    }, {
      text: "Leaderboards",
      url: course_leaderboards_url(@course),
      img: @theme_settings["Leaderboards Icon"],
      icon: "icon-star-empty"
    }, {
      text: "Students",
      url: course_students_url(@course),
      icon: "icon-user",
    }]

    if can? :manage, Course
      @nav_items << {
          text: "Manage Stuff",
          url:  course_stuff_url(@course),
          icon: "icon-user"
      }
      if curr_user_course.is_stuff?
        @nav_items << {
            text: "My Students",
            url: course_manage_students_url(@course),
            icon: "icon-user"
        }
      end

      @nav_items << {
        text: "Tags",
        url: course_tags_url(@course),
        icon: "icon-tags"
      }
      @nav_items << {
        text: "Award Give-away",
        url: course_manual_exp_url(@course),
        icon: "icon-star"
      }
      @nav_items << {
        text: "Statistics",
        url: course_stats_url(@course),
        icon: "icon-bar-chart"
      }
      @nav_items << {
        text: "Enrollment",
        url: course_enroll_requests_url(@course),
        icon: "icon-bolt"
      }
      @nav_items << {
        text: "Settings",
        url: edit_course_url(@course),
        icon: "icon-cog"
      }
    end
    if can? :share, Course
      @nav_items << {
        text: "Duplicate Data",
        url: course_duplicate_url(@course),
        icon: "icon-bolt"
      }
    end
  end

  def load_popup_notifications
    if curr_user_course.id
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

  def signed_in_user
    unless current_user
      redirect_to new_user_session_path, alert: "You need to sign in or sign up before continuing."
    end
  end

  private
  def current_ability
    if @course
      @current_ability ||= CourseAbility.new(current_user, curr_user_course)
    else
      @current_ability ||= Ability.new(current_user)
    end
  end

  helper_method :curr_user_course
end
