class ApplicationController < ActionController::Base

  protect_from_forgery
  helper_method :sort_direction, :sort_column
  before_filter :init_gon
  skip_before_filter  :verify_authenticity_token

  rescue_from CanCan::AccessDenied do |exception|

    unless current_user
      session[:request_url] = request.url
    end

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
  end

  def init_gon
    gon.push :gon => true
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

  def load_sidebar_notifications
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
      counts[:surveys]  = @course.pending_surveys(curr_user_course).count

      all_materials = Material.where(folder_id: (curr_user_course.is_student? ?
          @course.material_folders.opened_folder :
          @course.material_folders)).accessible_by(current_ability)
      unseen_materials = all_materials - curr_user_course.seen_materials
      counts[:materials] = unseen_materials.count

      all_comics = @course.accessible_comics(curr_user_course)
      unseen_comics = all_comics - curr_user_course.seen_comics
      counts[:comics] = unseen_comics.count

      #if can? :see_all, Submission
      #  # lecturers see number of new submissions of all students in the course
      #  all_sbms = @course.submissions.accessible_by(current_ability) +
      #      @course.training_submissions.accessible_by(current_ability)
      #  unseen_sbms = all_sbms - curr_user_course.get_seen_sbms
      #  counts[:submissions] = unseen_sbms.count
      #end
      if can? :see, :pending_grading
        counts[:pending_grading] = @course.get_pending_gradings(curr_user_course).count
      end
      if can? :see, :pending_comments
        counts[:pending_comments] = @course.count_pending_comments
      end
      counts[:pending_enrol] = @course.enroll_requests.count
      # TODO students see the number of new gradings

      counts[:forums] = ForumTopic.unread(curr_user_course).
          where(forum_id: @course.forums.accessible_by(current_ability)).count
    end
  end

  def load_sidebar_data
    counts = {}
    # in the future, nav items can be loaded from the database
    @nav_items = []
    # home

    if curr_user_course.is_student?
      @course.student_sidebar_display.each do |item|
        item_name = item.preferable_item.name
        url_and_icon = get_url_and_icon(item_name)
        @nav_items << {
            text: item.prefer_value,
            url:  url_and_icon.first,
            icon: url_and_icon.last,
            count: counts[item_name.to_sym] || 0
        }
      end
    end

    if can? :manage, Course
      @nav_items = [{
                        text:   @course.customized_title_by_model(Announcement),
                        url:    main_app.course_announcements_url(@course),
                        img:    @theme_settings["Announcements Icon"],
                        icon:   "icon-bullhorn",
                        count:  counts[:announcements] || 0
                    }, {
                        text:   @course.customized_title_by_model(Mission),
                        url:    main_app.course_missions_url(@course),
                        img:    @theme_settings["Missions Icon"],
                        icon:   "icon-fighter-jet",
                        count:   counts[:missions] || 0
                    }, {
                        text:   @course.customized_title_by_model(Training),
                        url:    main_app.course_trainings_url(@course),
                        img:    @theme_settings["Trainings Icon"],
                        icon:   "icon-upload-alt",
                        count:  counts[:trainings] || 0
                    }, {
                        text:   @course.customized_title_by_model(Submission),
                        url:    main_app.course_submissions_url(@course),
                        img:    @theme_settings["Submissions Icon"],
                        icon:   "icon-envelope-alt",
                        #count:  counts[:submissions] || 0
                    }, {
                        text:   @course.customized_lesson_plan_title,
                        url:    main_app.course_lesson_plan_url(@course),
                        img:    @theme_settings["Lesson Plan Icon"],
                        icon:   "icon-time"
                    }, {
                        text:   @course.customized_materials_title,
                        url:    main_app.course_materials_url(@course),
                        img:    @theme_settings["Materials Icon"],
                        icon:   "icon-download",
                        count:  counts[:materials] || 0
                    }, {
                        text:   "Comics",
                        url:    main_app.course_comics_url(@course),
                        img:    @theme_settings["Comics Icon"],
                        icon:   "icon-picture",
                        count:  counts[:comics] || 0
                    }]
      @nav_items <<   {
          text:   @course.customized_title_by_model(Comment),
          url:    main_app.course_comments_url(@course),
          icon:   "icon-comments",
          count:  counts[:pending_comments] || 0
      }
      @nav_items <<    {
          text: "Pending Gradings",
          url:  main_app.course_pending_gradings_url(@course),
          icon: "icon-question-sign",
          count: counts[:pending_grading] || 0
      }
      @nav_items << {
          text:   @course.customized_title_by_model(Achievement),
          url:    main_app.course_achievements_url(@course),
          icon:   "icon-trophy"
      }
      @nav_items <<    {
          text:   @course.customized_leaderboard_title,
          url:    main_app.course_leaderboards_url(@course),
          img:    @theme_settings["Leaderboards Icon"],
          icon:   "icon-star-empty"
      }
      @nav_items <<    {
          text:   @course.customized_students_title,
          url:    main_app.course_students_url(@course),
          icon:   "icon-group",
      }
      @nav_items << {
          text: @course.customized_title_by_model(Survey),
          url: main_app.course_surveys_path(@course),
          icon: "icon-edit"
      }
      @nav_items << {
          text:   @course.customized_title("Forums"),
          url:    main_app.course_forums_url(@course),
          icon:   "icon-th-list",
          count: counts[:forums]
      }
    end

    if can? :manage, Course
      @admin_nav_items = []
      if curr_user_course.is_staff?
        @admin_nav_items << {
            text: "My Students",
            url: main_app.course_manage_group_url(@course),
            icon: "icon-group"
        }
        @admin_nav_items << {
            text: "Forum Participation",
            url:  main_app.course_forum_participation_url(@course),
            icon: "icon-group"
        }
      end
      @admin_nav_items << {
          text: "Manage Staff",
          url:  main_app.course_staff_url(@course),
          icon: "icon-user"
      }
      @admin_nav_items << {
          text: "Manage Students",
          url:  main_app.course_manage_students_url(@course),
          icon: "icon-user"
      }

      @admin_nav_items << {
          text: "Student Summary",
          url:  main_app.course_student_summary_url(@course),
          icon: "icon-user"
      }

      @admin_nav_items << {
          text: "Tutor Summary",
          url: main_app.course_staff_monitoring_path(@course),
          icon: "icon-trophy"
      }
      @admin_nav_items << {
          text:   "Levels",
          url:    main_app.course_levels_url(@course),
          icon:   "icon-star-empty"
      }

      @admin_nav_items << {
          text: "Tags",
          url: main_app.course_tags_url(@course),
          icon: "icon-tags"
      }
      @admin_nav_items << {
          text: "Award Give-away",
          url: main_app.course_manual_exp_url(@course),
          icon: "icon-star"
      }
      @admin_nav_items << {
          text: "Statistics",
          url: main_app.course_stats_url(@course),
          icon: "icon-bar-chart"
      }

      @admin_nav_items << {
          text: "Enrollment",
          url: main_app.course_enroll_requests_url(@course),
          icon: "icon-bolt",
          count: counts[:pending_enrol] || 0
      }

      @admin_nav_items << {
          text: "Mass Enrollment",
          url: main_app.course_mass_enrollment_emails_path(@course),
          icon: "icon-bolt"
      }

      @admin_nav_items << {
          text: "Duplicate Data",
          url: main_app.course_duplicate_url(@course),
          icon: "icon-bolt"
      }

      @admin_nav_items << {
          text: "Course Settings",
          url: main_app.edit_course_url(@course),
          icon: "icon-cog"
      }
      @admin_nav_items << {
          text: "Preference Settings",
          url: main_app.course_preferences_path(@course),
          icon: "icon-cog"
      }
    end

  end

  def load_popup_notifications
    if curr_user_course.id && curr_user_course.is_student?
      # for now all notifications are popup
      @popup_notifications = curr_user_course.get_unseen_notifications
      @popup_notifications.each do |popup|
        curr_user_course.mark_as_seen(popup)
      end
    end
  end

  def load_general_course_data
    if @course
      gon.course = { id: @course.id }
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

  def sort_direction
    params[:direction]
  end

  def sort_column
    params[:sort]
  end

  private
  def current_ability
    if @course
      @current_ability ||= CourseAbility.new(current_user, curr_user_course)
    else
      @current_ability ||= Ability.new(current_user)
    end
  end

  def masquerading?
    #puts session.to_json
    session[:admin_id].present?
  end

  #def fb_liked?
  #  @oauth = Koala::Facebook::OAuth.new(Facebook::APP_ID.to_s, Facebook::SECRET.to_s)
  #  @oauth.get_app_access_token
  #  likes = @oauth.get_connections("me", "likes")
  #
  #  puts likes
  #end


  def get_url_and_icon(item)
    url = root_path
    icon = 'icon-star'
    case item
      when 'announcements'
        url = main_app.course_announcements_path(@course)
        icon = 'icon-bullhorn'
      when 'missions'
        url = main_app.course_missions_url(@course)
        icon = 'icon-fighter-jet'
      when 'trainings'
        url = main_app.course_trainings_path(@course)
        icon = 'icon-upload-alt'
      when 'submissions'
        url = main_app.course_submissions_path(@course)
        icon = 'icon-envelope-alt'
      when 'achievements'
        url = main_app.course_achievements_url(@course)
        icon = 'icon-trophy'
      when 'leaderboard'
        url =  main_app.course_leaderboards_url(@course)
        icon = 'icon-star-empty'
      when 'students'
        url = main_app.course_students_url(@course)
        icon = 'icon-group'
      when 'comments'
        url = main_app.course_comments_url(@course)
        icon = 'icon-comments'
      when 'surveys'
        url = main_app.course_surveys_path(@course)
        icon = 'icon-edit'
      when 'forums'
        url = main_app.course_forums_url(@course)
        icon = 'icon-th-list'
      when 'lesson_plan'
        url = main_app.course_lesson_plan_path(@course)
        icon = 'icon-time'
      when 'materials'
        url = main_app.course_materials_path(@course)
        icon = 'icon-download'
      when 'comics'
        url = main_app.course_comics_path(@course)
        icon = 'icon-picture'
    end
    [url, icon]
  end

  helper_method :masquerading?
  helper_method :curr_user_course
  #helper_method :fb_liked?
end
