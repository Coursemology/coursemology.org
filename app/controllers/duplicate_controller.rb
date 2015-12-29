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
        Mission: @course.assessments.mission,
        Training: @course.assessments.training,
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

  def handle_question_relationship(assessment)
    qns_logs = assessment.questions.all_dest_logs
    question_above = Array.new
    assessment.questions.each do |qn|
      unless qn.dependent_on
        next
      end
      l = (qn.dependent_on.duplicate_logs_orig & qns_logs).first
      unless l
        next
      end

      if question_above.include?(l.dest_obj_id)
        qn.dependent_id = l.dest_obj_id
      else
        qn.dependent_id = nil
      end
      qn.save
      question_above << qn.id
    end
  end

  def handle_dup_questions_position(dup)
    pos = 0
    dup.questions.each do |qn|
      dqa = qn.question_assessments.where(assessment_id: dup.id).first
      dqa.position = pos
      dqa.save
      pos += 1
    end
  end

  def assign_tab_id(assessment, training_tab, mission_tab)
    if assessment.is_a? Assessment::Training
      if training_tab
        assessment.tab_id = training_tab.id
      else
        assessment.tab_id = 0
      end
    else
      if mission_tab
        assessment.tab_id = mission_tab.id
      else
        assessment.tab_id = 0
      end
    end
    assessment.save
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

    training_tab = dest_course.tabs.training.first
    mission_tab = dest_course.tabs.mission.first

    (assessments + achievements + levels + milestones + entries +
        forums + surveys).each do |record|
       c = record.amoeba_dup
       c.course = dest_course
       if record.respond_to? :dependent_on
         record.dependent_on = []
        end
       c.save
       if c.is_a? Assessment
         handle_dup_questions_position(c)
         handle_question_relationship(c)
         assign_tab_id(c, training_tab, mission_tab)
       end
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

    shift_dates(clone.lesson_plan_milestones + clone.lesson_plan_entries, options[:course_diff], [:start_at, :end_at])
    shift_dates(clone.assessments, options[:course_diff], [:open_at, :close_at, :bonus_cutoff_at])
    shift_dates(clone.surveys, options[:course_diff], [:open_at, :expire_at])
    shift_dates(clone.material_folders, options[:course_diff])

    clone.assessments.each do |assessment|
      assessment.create_or_destroy_tasks
    end

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
      t_map[tab.id] = tab.duplicate_logs_dest.order("created_at desc").first.origin_obj_id
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
    asm_req_logs = clone.assessments.map { |asm| asm.as_asm_reqs.all_dest_logs}.flatten
    asm_logs = clone.assessments.all_dest_logs
    lvl_logs = clone.levels.all_dest_logs
    ach_logs = clone.achievements.all_dest_logs
    logs = asm_req_logs + lvl_logs + ach_logs

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
      if asm.dependent_on.count == 0
        next
      end
      c = []
      asm.dependent_on.each do |dep_asm|
        l = (dep_asm.duplicate_logs_orig & asm_logs).first
        if l
          c << clone.assessments.find(l.dest_obj_id)
        end
      end
      asm.dependent_on = c
      asm.save
    end


    #question position & dependency
    clone.assessments.each do |asm|
      handle_dup_questions_position(asm)
      handle_question_relationship(asm)
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

  def shift_dates(time_records, date_shift, date_columns = [:open_at, :close_at])
    return if !date_shift || date_shift == 0

    Array(time_records).each do |record|
      Array(date_columns).each do |column|
        record.update_column(column, record.send(column) + date_shift) if record.send(column)
      end
    end
  end
end
