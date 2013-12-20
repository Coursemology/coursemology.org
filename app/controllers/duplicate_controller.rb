class DuplicateController < ApplicationController
  load_and_authorize_resource :course
  before_filter :load_general_course_data, only: [:manage]


  def manage
    authorize! :can, :duplicate, @course
    @missions = @course.missions
    @trainings = @course.trainings
    lecturer_courses = current_user.user_courses.lecturer
    @my_courses = lecturer_courses.map { |uc| uc.course }
    @duplicable_items = {
        Mission     => @course.missions,
        Training    => @course.trainings,
        Achievement => @course.achievements,
        Level       => @course.levels,
        TagGroup    => @course.tag_groups,
        MaterialFolder  => @course.material_folder,
        LessonPlanMilestone => @course.lesson_plan_milestones,
        ForumForum          => @course.forums,
        Survey              => @course.surveys
    }
    first_mission = @course.missions.first
    first_training = @course.trainings.first
    @dates = {
        course: @course.start_at,
        mission: unless first_mission then nil else first_mission.open_at end,
        training: unless first_training then nil else first_training.open_at end
    }
    puts @dates
  end

  def duplicate_assignments
    require 'duplication'
    dest_course = Course.find(params[:dest_course])
    authorize! :manage, dest_course
    authorize! :duplicate, @course

    training_ids = params[Training.model_name] || []
    training_ids.each do |id|
      training = @course.trainings.find(id)
      if training
        Duplication.duplicate_asm(current_user, training, @course, dest_course)
      end
    end
    #
    mission_ids = params[Mission.model_name] || []
    mission_ids.each do |id|
      mission = @course.missions.find(id)
      if mission
        Duplication.duplicate_asm(current_user, mission, @course, dest_course)
      end
    end

    achievement_ids   = params[Achievement.model_name] || []
    achievements = @course.achievements.where(id:achievement_ids)

    levels = []
    if dest_course.levels.length == 1
      level_ids         = params[Level.model_name] || []
      levels = @course.levels.where(id: level_ids)
    end

    lesson_plan_milestone_ids = params[LessonPlanMilestone.model_name] || []
    milestones = @course.lesson_plan_milestones.where(id: lesson_plan_milestone_ids)

    lesson_plan_entry_ids     = params[LessonPlanEntry.model_name] || []
    entries = @course.lesson_plan_entries.where(id: lesson_plan_entry_ids)

    forum_ids                 = params[ForumForum.model_name] || []
    forums = @course.forums.where(id: forum_ids)

    survey_ids                = params[Survey.model_name] || []
    surveys = @course.surveys.where(id: survey_ids)

    (achievements + levels + milestones + entries +
        forums + surveys).map {|record| Duplication.duplicate_record(current_user, record, @course, dest_course)}

    tag_group_ids = params[TagGroup.model_name] || []
    groups = @course.tag_groups.where(id: tag_group_ids)

    tag_ids = params[Tag.model_name] || []
    tags = @course.tags.where(id: tag_ids)

    groups.map {|grp| Duplication.duplicate_tag_group(current_user, grp, tags, @course, dest_course)}

    material_folder_ids = params[MaterialFolder.model_name] || []
    folders = @course.material_folder.subfolders.where(id: material_folder_ids)
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
      course_diff = Time.parse(params[:course_start]) - @course.start_at
    rescue
      course_diff =  0
    end

    begin
      mission_diff = Time.parse(params[:mission_start]) - @course.missions.first.open_at
    rescue
      mission_diff = 0
    end

    begin
      training_diff = Time.parse(params[:training_start]) - @course.trainings.first.open_at
    rescue
      training_diff =  0
    end

    options = {
        course_diff: course_diff,
        mission_diff: mission_diff,
        training_diff: training_diff,
        mission_files: params[:mission_files] == "true",
        training_files: params[:training_files] == "true",
        workbin_files: params[:workbin_files] == "true"
    }

    clone = Duplication.duplicate_course(current_user, @course, options)
    respond_to do |format|
      flash[:notice] = "The course '#{@course.title}' has been duplicated."
      format.html { redirect_to edit_course_path(clone) }

      format.json {render json: {url: edit_course_path(clone)} }
    end
  end
end
