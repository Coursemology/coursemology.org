class CoursePreferencesController < ApplicationController
  load_and_authorize_resource :course
  before_filter :load_general_course_data, only: [:edit]
  before_filter :authorize_preference_setting


  def edit
    @tab = params[:_tab]
    case @tab
      when 'mission'
        @tab = "MissionPreference"
        @preferences = @course.mission_columns
        @time_format =  @course.mission_time_format
        @auto_submit = @course.auto_create_sbm_pref
      when 'training'
        @tab = "TrainingPreference"
        @preferences = @course.training_columns
        @time_format =  @course.training_time_format
        @reattempt = @course.course_preferences.training_reattempt.first
      when 'mcq'
        @tab = "McqPreference"
        @mcq_auto_grader = @course.mcq_auto_grader
      when 'email'
        @tab = "NotificationPreference"
        @preferences = @course.email_notifications
      when 'other'
        @tab = "OtherPreference"
        @preferences = @course.home_sections
        @no_preferences = @course.course_home_events_no_pref << @course.leaderboard_no_pef
        @achievement_pref = @course.achievements_locked_display
      when 'paging'
        @tab = 'PagingPreference'
        @preferences = @course.course_paging_prefs
      when 'sidebar'
        @tab = 'Sidebar'
        @ranking = @course.student_sidebar_ranking
      else
        @tab = 'CoursePreference'
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
  end

  def update
    #dalli don't support regualr expression
    Role.all.each do |role|
      expire_fragment("sidebar/#{@course.id}/role/#{role.id}")
    end

    @course.update_attributes(params[:course])
    preferences = params[:preferences]
    preferences.each do |val, key|
      curr_pref = @course.course_preferences.where(id: val).first
      if curr_pref
        if key["prefer_value"] && key["prefer_value"].strip.size > 0
          curr_pref.prefer_value = key["prefer_value"].strip
        end
        curr_pref.display = key["display"] ? true : false
        curr_pref.save
      end
    end
    redirect_to params[:origin], :notice => "Updated successfully"
  end
  private
  def authorize_preference_setting
    authorize! :manage, :course_preference
  end

end
