class ApplicationController < ActionController::Base

  protect_from_forgery
  helper_method :sort_direction, :sort_column
  before_filter :init_gon
  skip_before_filter  :verify_authenticity_token
  around_filter :set_time_zone, if: :current_user

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
    atts << ThemeAttribute.find_by_name('Cust om CSS')
    # atts << ThemeAttribute.find_by_name('Announcements Icon')
    # atts << ThemeAttribute.find_by_name('Missions Icon')
    # atts << ThemeAttribute.find_by_name('Trainings Icon')
    # atts << ThemeAttribute.find_by_name('Submissions Icon')
    # atts << ThemeAttribute.find_by_name('Leaderboards Icon')
    # atts << ThemeAttribute.find_by_name('Background Image')

    @theme_settings = {}
    atts.each do |att|
      if att
        ca = CourseThemeAttribute.where(course_id: @course.id, theme_attribute_id:att.id).first_or_create
        @theme_settings[att.name] = ca.value
      end
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

  def sidebar_general_items
    general_items = []

    @course.navbar_tabs(curr_user_course.is_staff?).each do |item|
      url_and_icon = get_url_and_icon(item.item)
      general_items << {
          item: item.item,
          text: item.name,
          url:  url_and_icon.first,
          icon: url_and_icon.last,
      }
    end

    #TO REMOVE
    if can? :manage, @course

      general_items <<    {
          item: "pending_gradings",
          text: "Pending Gradings",
          url:  main_app.course_pending_gradings_url(@course),
          icon: "icon-question-sign",
      }
    end

    general_items
  end

  def sidebar_admin_items
    admin_nav_items = []
    if curr_user_course.is_staff?
      admin_nav_items += [{
                              text: "Forum Participation",
                              url:  main_app.course_forum_participation_url(@course),
                              icon: "icon-group"
                          }]
    end
    admin_nav_items += [{
                           text: "Manage Users",
                           url:  main_app.course_manage_students_url(@course),
                           icon: "icon-user"
                       },{
                           text: "Student Summary",
                           url:  main_app.course_student_summary_url(@course),
                           icon: "icon-user"
                       },{
                           text: "Staff Summary",
                           url: main_app.course_staff_monitoring_path(@course),
                           icon: "icon-trophy"
                       },{
                           text:   "Levels",
                           url:    main_app.course_levels_url(@course),
                           icon:   "icon-star-empty"
                       },{
                           text: "Tags",
                           url: main_app.course_tags_url(@course),
                           icon: "icon-tags"
                       },{
                           text: "Award Give-away",
                           url: main_app.course_manual_exp_url(@course),
                           icon: "icon-star"
                       }, {
                           text: "Statistics",
                           url: main_app.course_stats_url(@course),
                           icon: "icon-bar-chart"
                       },{
                           text: "Enrollment",
                           url: main_app.course_enroll_requests_url(@course),
                           icon: "icon-bolt"
                       }, {
                           text: "Duplicate Data",
                           url: main_app.course_duplicate_url(@course),
                           icon: "icon-bolt"
                       }]
    if can? :manage, :course_admin
      admin_nav_items << {
          text: "Settings",
          url: main_app.course_preferences_path(@course),
          icon: "icon-cog"
      }
    end
    admin_nav_items
  end


  def load_sidebar_data
    # in the future, nav items can be loaded from the database
    # home
    @nav_items = Rails.cache.fetch("nav_items_#{@course.id}_#{curr_user_course ? curr_user_course.role_id : 0}") { sidebar_general_items }

    if can? :manage, @course
      @admin_nav_items = Rails.cache.fetch("admin_nav_items_#{@course.id}") { sidebar_admin_items }
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

  def load_settings_for_printing
    @format_for_printing = true
    @add_page_breaks = params[:add_page_breaks].present?
    @hide_timestamps = params[:hide_timestamps].present?
    @hide_wrong_attempts = params[:hide_wrong_attempts].present?
    @hide_comments = params[:hide_comments].present?
    @hide_annotations = params[:hide_annotations].present?
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
        url = main_app.course_assessment_missions_path(@course)
        icon = 'icon-fighter-jet'
      when 'trainings'
        url = main_app.course_assessment_trainings_path(@course)
        icon = 'icon-upload-alt'
      when 'submissions'
        url = main_app.submissions_course_assessment_missions_path(@course)
        icon = 'icon-envelope-alt'
      when 'achievements'
        url = main_app.course_achievements_path(@course)
        icon = 'icon-trophy'
      when 'leaderboard'
        url =  main_app.course_leaderboards_path(@course)
        icon = 'icon-star-empty'
      when 'students'
        url = main_app.course_students_path(@course)
        icon = 'icon-group'
      when 'comments'
        url = main_app.course_comments_path(@course)
        icon = 'icon-comments'
      when 'surveys'
        url = main_app.course_surveys_path(@course)
        icon = 'icon-edit'
      when 'forums'
        url = main_app.course_forums_path(@course)
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
      when 'guilds'
        url = main_app.course_guilds_path(@course)
        icon = 'icon-home'
    end
    [url, icon]
  end

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  helper_method :masquerading?
  helper_method :curr_user_course
  #helper_method :fb_liked?

  def set_time_zone(&block)
    Time.use_zone(current_user.try(:time_zone), &block)
  end
end
