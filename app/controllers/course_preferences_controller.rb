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
      else
        @tab = 'Sidebar'
        @ranking = @course.student_sidebar_ranking
        
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
  
  def sidebar_update_values
    #dalli don't support regualr expression
    Role.all.each do |role|
      expire_fragment("sidebar/#{@course.id}/role/#{role.id}")
    end    
    
    cnp = CourseNavbarPreference.find(params[:id])
    cnp_arr = []
    case params[:func]
      when 'add'
        cnp.is_enabled = true    
      when 'remove'
        cnp.is_enabled = false
      when 'update_name'
        cnp.name = params[:name]
      when 'update_pos'        
        if params[:pos].to_i > params[:old_pos].to_i
          CourseNavbarPreference.where(:course_id => @course.id).where('pos > ? and pos <= ?',params[:old_pos],params[:pos]).each do |c|
            c.pos = c.pos - 1
            cnp_arr << c     
          end
        elsif params[:pos].to_i < params[:old_pos].to_i
          CourseNavbarPreference.where(:course_id => @course.id).where(' pos >= ? and pos < ?',params[:pos],params[:old_pos]).each do |c|
            c.pos = c.pos + 1
            cnp_arr << c           
          end
        end
        cnp.pos = params[:pos]
      when 'update_is_displayed'
        cnp.is_displayed = params[:checked]=='true' ? 1 : 0         
    end    
    
    respond_to do |format|      
      if cnp.save         
        if params[:func] == 'add' || params[:func] == 'update_pos'
          if cnp_arr.count > 0
            cnp_arr.each do |c|
              c.save
            end
          end
          tags = @course.course_navbar_preferences.where(is_enabled: true).order(:pos)
          new_index = tags.find_index{ |item| item.id.to_s == params[:id] }
          if params[:func] == 'add'
            url_and_icon = get_url_and_icon(cnp.item);
            format.json { render json: { index: new_index,
                                         count: tags.count,
                                         name: cnp.name,
                                         id: cnp.id,
                                         item: cnp.item,
                                         url: url_and_icon.first,
                                         icon: url_and_icon.last
                                       }
            } 
          else
            format.json { render json: { index: new_index, count: tags.count }}
          end           
        else          
          format.json { render json: { status: 'OK' }}    
        end    
      else
        format.json { render json: {errors: 'Fail'}}
        flash[:error] ='Update failed. You may entered invalid name or email.'        
      end
      
    end
  end
  
  def update_display_student_level_achievement
    curr_pref = @course.course_preferences.find(params[:id])
    curr_pref.display = params[:checked]=='true' ? 1 : 0
    
    respond_to do |format|
      if curr_pref.save
        format.json { render json: { status: 'OK' }}
      end
    end
  end
  
  private
  def authorize_preference_setting
    authorize! :manage, :course_preference
  end

end
