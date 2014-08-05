class DuplicateController < ApplicationController
  load_and_authorize_resource :course
  before_filter :load_general_course_data, only: [:manage]


  def manage
    authorize! :duplicate, @course
    @missions = @course.missions
    @trainings = @course.trainings
    staff_courses = current_user.user_courses.staff
    @my_courses = staff_courses.map { |uc| uc.course }
    @duplicable_items = {
        Mission: @course.missions,
        Training: @course.trainings,
        Achievement: @course.achievements,
        Level: @course.levels,
        TagGroup: @course.tag_groups,
        MaterialFolder: @course.root_folder,
        LessonPlanMilestone: @course.lesson_plan_milestones,
        Forum:  @course.forums,
        Survey: @course.surveys
    }

    @dates = {
        course: @course.start_at ? @course.start_at.to_date : nil,
    }
  end

  def duplicate_assignments
    require 'duplication'
    dest_course = Course.find(params[:dest_course])
    authorize! :manage, dest_course
    authorize! :duplicate, @course

    assessments = @course.assessments.where(id: (params[:Training] || []) + (params[:Mission] || []))
    achievements = @course.achievements.where(id: params[:Achievement] || [])
    levels = @course.levels.where(id: params[:Level] || [])
    milestones = @course.lesson_plan_milestones.where(id: params[:LessonPlanMilestone] || [])
    entries = @course.lesson_plan_entries.where(id: params[:LessonPlanEntry] || [])
    forums = @course.forums.where(id: params[:Forum] || [])
    surveys = @course.surveys.where(id: params[:Survey] || [])

    (assessments + achievements + levels + milestones + entries +
        forums + surveys).each do |record|
       c = record.amoeba_dup
       c.course = dest_course
       if record.respond_to? dependent_id
         record.dependent_id = 0
       end
       c.save
    end


    tag_group_ids = params[:TagGroup] || []
    groups = @course.tag_groups.where(id: tag_group_ids)

    tag_ids = params[Tag.model_name] || []
    tags = @course.tags.where(id: tag_ids)

    groups.map {|grp| Duplication.duplicate_tag_group(current_user, grp, tags, @course, dest_course) }

    material_folder_ids = params[:MaterialFolder] || []
    folders = @course.root_folder.subfolders.where(id: material_folder_ids)
    folders.map {|folder| Duplication.duplicate_folder(current_user, folder, @course, dest_course) }


    respond_to do |format|
      format.html { redirect_to course_path(dest_course),
                                notice: "The specified items have been duplicated." }
    end
  end

  def duplicate_course
    authorize! :duplicate, @course
    authorize! :create, Course

    require 'duplication'
    begin
      course_diff = Time.parse(params[:to_date]) -  Time.parse(params[:from_date])
    rescue
      course_diff =  0
    end

    mission_diff =  course_diff
    training_diff = course_diff

    options = {
        course_diff: course_diff,
        mission_diff: mission_diff,
        training_diff: training_diff,
        mission_files: params[:mission_files] == "true",
        training_files: params[:training_files] == "true",
        workbin_files: params[:workbin_files] == "true"
    }
    #
    Course.skip_callback(:create, :after, :initialize_default_settings)
    Assessment.skip_callback(:save, :after, :update_opening_tasks)
    Assessment.skip_callback(:save, :after, :update_closing_tasks)
    Assessment.skip_callback(:save, :after, :create_or_destroy_tasks)
    clone = @course.amoeba_dup
    clone.creator = current_user
    user_course = clone.user_courses.build
    user_course.user = current_user
    user_course.role = Role.find_by_name(:lecturer)
    clone.start_at = clone.start_at ? clone.start_at + options[:course_diff] : clone.start_at
    clone.end_at =  clone.end_at ? clone.end_at + options[:course_diff] : clone.end_at

    clone.save
    handle_relationships(clone)
    Course.set_callback(:create, :after, :initialize_default_settings)
    Assessment.set_callback(:save, :after, :update_opening_tasks)
    Assessment.set_callback(:save, :after, :update_closing_tasks)
    Assessment.set_callback(:save, :after, :create_or_destroy_tasks)

    respond_to do |format|
      flash[:notice] = "The course '#{@course.title}' has been duplicated."
      format.html { redirect_to course_preferences_path(clone) }

      format.json {render json: {url: course_preferences_path(clone)} }
    end
  end

  def handle_relationships(clone)
    #handle relation tables
    #tab
    t_map = {}
    clone.tabs.each do |tab|
      t_map[tab.id] = tab.duplicate_logs_dest.first.origin_obj_id
    end
    t_map.each do |k, v|
      sql = "UPDATE assessments SET tab_id = #{k} WHERE course_id =#{clone.id} AND tab_id = #{v}"
      ActiveRecord::Base.connection.execute(sql)
    end

    #subfolders
    clone.root_folder.subfolders.each do |f|
      f.course = clone
      f.save
    end

    #achievements requirements
    asm_logs = clone.assessments.all_dest_logs
    lvl_logs = clone.levels.all_dest_logs
    ach_logs = clone.achievements.all_dest_logs
    logs = asm_logs + lvl_logs + ach_logs

    clone.achievements.each do |ach|
      ach.requirements.each do |ar|
        l = (ar.req.duplicate_logs_orig & logs).first
        unless l
          next
        end
        ar.req = l.dest_obj
        ar.save
      end
    end

    #assessment dependency
    clone.assessments.each do |asm|
      unless asm.dependent_on
        next
      end
      l = (asm.dependent_on.duplicate_logs_orig & asm_logs).first
      unless l
        next
      end
      asm.dependent_id = l.dest_obj_id
      asm.save
    end

    #tags
    clone.tag_groups.each do |tg|
      tg.tags.each do |t|
        t.course = tg.course
        t.save
      end
    end
    q_logs = clone.questions.all_dest_logs
    clone.taggings.each do |tt|
      l = (tt.taggable.duplicate_logs_orig & q_logs).first
      unless l
        next
      end
      tt.taggable = l.dest_obj
      tt.save
    end
  end
end
