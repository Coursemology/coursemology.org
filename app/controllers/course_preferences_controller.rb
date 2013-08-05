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
      when 'training'
        @tab = "TrainingPreference"
        @preferences = @course.training_columns
        @time_format =  @course.training_time_format
      when 'email'
        @tab = "NotificationPreference"
        @preferences = @course.email_notifications
      else
        @tab = 'Sidebar'
        @preferences = @course.student_sidebar_items
    end
  end

  def update
       preferences = params[:preferences]
       preferences.each do |val, key|
         curr_pref = @course.course_preferences.where(id: val).first
         if curr_pref
           if key["prefer_value"] && key["prefer_value"].strip.size > 0
             curr_pref.prefer_value = key["prefer_value"]
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
