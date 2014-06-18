class Assessment::MissionsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :mission, class: "Assessment::Mission", through: :course

  before_filter :load_general_course_data, only: [:show, :index, :new, :edit, :access_denied, :stats, :overview]

  require 'zip/zipfilesystem'

  def index
    @tab = 'missions'
    @is_new = {}
    selected_tags = params[:tags]
    @display_columns = {}
    @course.mission_columns_display.each do |cp|
      @display_columns[cp.preferable_item.name] = cp.prefer_value
    end
    @time_format =  @course.mission_time_format

    @missions = @course.missions
    @paging = @course.missions_paging_pref


    if selected_tags
      tags = Tag.find(selected_tags)
      mission_ids = tags.map { |tag| tag.missions.map{ |t| t.id } }.reduce(:&)
      @missions = @missions.where(id: mission_ids)
    end

    if @paging.display?
      @missions = @missions.accessible_by(current_ability).page(params[:page]).per(@paging.prefer_value.to_i)
    end

    @submissions = @course.submissions.where(assessment_id: @missions.map {|m| m.assessment.id},
                                             std_course_id: curr_user_course.id)

    sub_ids = @submissions.map {|s| s.mission_id }
    sub_map = {}
    @submissions.each do |sub|
      sub_map[sub.mission_id] = sub
    end

    action_map = {}
    @missions.each do |m|
      if sub_ids.include? m.id
        attempting = sub_map[m.id].attempting?
        action_map[m.id] = {action: attempting ? "Edit" : "Review",
                            url: edit_course_assessment_mission_assessment_submission_path(@course, m, sub_map[m.id]) }
      elsif  m.dependent_id == 0 or
          can?(:manage, m) or
          (sub_ids.include? m.dependent_id and sub_map[m.dependent_id].submitted?)
        action_map[m.id] = {action: "Attempt",
                            url: new_course_assessment_mission_assessment_submission_path(@course, m)}
      else
        action_map[m.id] = {action: nil}
      end
      action_map[m.id][:new] = false
      action_map[m.id][:opened] = m.open_at <= Time.now
      action_map[m.id][:published] = m.published
      action_map[m.id][:title_link] =
          can?(:manage, m) ?
          course_assessment_mission_stats_path(@course, m) :
          course_assessment_mission_path(@course, m)
    end

    if curr_user_course.id
      unseen = @missions - curr_user_course.seen_missions
      unseen.each do |um|
        action_map[um.id][:new] = true
        curr_user_course.mark_as_seen(um)
      end
    end
    @summary = {selected_tags: selected_tags, actions: action_map}

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def show
    if curr_user_course.is_student? and !@mission.can_start?(curr_user_course).first
      redirect_to course_assessment_missions_path
      return
    end

    @questions = @mission.get_all_questions
    @question = Assessment::GeneralQuestion.new
    @question.max_grade = 10
    @coding_question = Assessment::CodingQuestion.new
    @coding_question.max_grade = 10
    respond_to   do |format|
      format.html # show.html.erb
    end
  end

  def new
    @missions = @course.missions
    @mission.exp = 1000
    @mission.open_at = DateTime.now.beginning_of_day
    @mission.close_at = DateTime.now.end_of_day + 7  # 1 week from now
    @mission.course_id = @course.id
    puts @mission.assessment.to_json

    @tags = @course.tags
    @asm_tags = {}

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  def edit
    @missions = @course.missions
    @tags = @course.tags
    @asm_tags = {}
    @mission.asm_tags.each { |asm_tag| @asm_tags[asm_tag.tag_id] = true }
  end

  def create
    @missions = @course.missions
    @mission.position = @course.missions.count + 1
    @mission.creator = current_user
    @mission.course_id = @course.id
    if params[:files]
      @mission.attach_files(params[:files].values)
    end
    @mission.update_tags(params[:tags])
    if @mission.single_question?
      qn = params[:answer_type] == 'code' ? @mission.coding_questions.build : @mission.questions.build
      qn.max_grade = params[:max_grade]
    end

    respond_to do |format|
      if @mission.save
        @mission.create_local_file
        @mission.update_grade
        @mission.schedule_tasks(course_assessment_mission_url(@course, @mission))
        format.html { redirect_to course_assessment_mission_path(@course, @mission),
                                  notice: "The mission #{@mission.title} has been created." }
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    @mission.update_tags(params[:tags])

    respond_to do |format|
      if @mission.update_attributes(params[:mission])

        if @mission.single_question? && @mission.get_all_questions.count > 1
          flash[:error] = "Mission already have several questions, can't change the format."
          @mission.single_question = false
          @mission.save
        end
        update_single_question_type
        update_mission_max_grade

        @mission.schedule_tasks(course_mission_url(@course, @mission))
        format.html { redirect_to course_mission_url(@course, @mission),
                                  notice: "The mission #{@mission.title} has been updated." }
      else
        format.html {redirect_to edit_course_mission_path(@course, @mission) }
      end
    end
  end

  def destroy
    @mission.destroy
    respond_to do |format|
      format.html { redirect_to course_assessment_missions_url,
                                notice: "The mission #{@mission.title} has been removed." }
    end
  end

  def update_mission_max_grade
    if @mission.single_question? && @mission.max_grade != params[:max_grade].to_i
      qn = @mission.get_all_questions.first
      qn.max_grade = params[:max_grade]
      qn.save
      @mission.update_grade
    end
  end

  def update_single_question_type
    puts "update single question"
    unless @mission.single_question?
      return
    end
    puts "get single question type"
    type = params[:answer_type] == 'code' ? CodingQuestion : Question
    previous_qn = @mission.get_all_questions.first
    if type != previous_qn.class
      if previous_qn
        previous_qn.destroy
      end
      qn = type == CodingQuestion ? @mission.coding_questions.build : @mission.questions.build
      qn.max_grade = params[:max_grade]
      @mission.save
      @mission.update_grade
    end
  end

  def stats
    @stats_paging = @course.missions_stats_paging_pref
    @submissions = @mission.submissions.all
    @std_courses = @course.user_courses.student.order(:name).where(is_phantom: false)
    @my_std_courses = curr_user_course.std_courses.student.order(:name).where(is_phantom: false)

    if @stats_paging.display?
      @std_courses = @std_courses.page(params[:page]).per(@stats_paging.prefer_value.to_i)
    end
    @std_courses_phantom = @course.user_courses.student.order(:name).where(is_phantom: true)
  end

  def overview
    authorize! :manage, :bulk_update
    @tab = 'overview'
    @display_columns = {}
    @course.mission_columns_display.each do |cp|
      @display_columns[cp.preferable_item.name] = cp.prefer_value
    end

    @missions = @course.missions.accessible_by(current_ability).order(:open_at)
  end

  def bulk_update
    authorize! :manage, :bulk_update
    missions = params[:missions]
    success = 0
    fail = 0
    missions.each do |key, val|
      mission = @course.missions.where(id:key).first
      mission.assign_attributes(val)
      unless mission.changed?
        next
      end
      if mission.save
        puts mission.to_json
        success += 1
      else
        fail += 1
      end
    end
    flash[:notice] = "#{success} mission(s) updated successfully."
    if fail > 0
      flash[:error] = "#{fail} mission(s) failed to update. You may have put an open time that is after end time."
    end
    redirect_to course_assessment_missions_overview_path
  end

  def access_denied
    respond_to   do |format|
      format.html # show.html.erb
    end
  end

  def dump_code

    case params[:_type]
      when 'mine'
        std_courses =  curr_user_course.std_courses
      when 'phantom'
        std_courses = @course.user_courses.student.where(is_phantom: true)
      else
        std_courses = @course.user_courses.student.where(is_phantom: false)
    end

    sbms = @mission.submissions.
        where("std_course_id IN (?) and status = 'graded'", std_courses.select("user_courses.id")).includes(:std_coding_answers)

    result = nil

    Dir.mktmpdir("mission-dump-temp-#{Time.now}") { |dir|
      sbms.each do |sbm|
        ans = sbm.std_coding_answers.first
        unless ans
          next
        end

        path = dir

        if sbm.files.count > 0
          title = sbm.std_course.name.gsub(/\//,"_")
          dir_path = File.join(dir, title)
          Dir.mkdir(dir_path) unless Dir.exists?(dir_path)
          sbm.files.each do |file|
            temp_path = File.join(dir_path, file.original_name.gsub(/\//,"_"))
            file.file.copy_to_local_file :original, temp_path
          end
          path = dir_path
        end

        title = "#{sbm.std_course.name.gsub(/\//,"_") }.py"
        file = File.open(File.join(path, title), 'w+')
        file.write(ans.code)
        file.close
      end

      zip_name = File.join(File.dirname(dir),
                           Dir::Tmpname.make_tmpname([@mission.title, ".zip"], nil))
      Zip::ZipFile.open(zip_name, Zip::ZipFile::CREATE) { |zipfile|
        # Add every file in the directory to the zip file, preserving structure.
        Dir[File.join(dir, '**', '**')].each {|file|
          zipfile.add(file.sub(File.join(dir + '/'), ''), file)
        }
      }

      result = zip_name
    }

    respond_to do |format|
      format.zip {
        #filename = build_zip @folder, :recursive => false, :include => params['include']
        send_file(result, {
            :type => "application/zip, application/octet-stream",
            :disposition => "attachment",
            :filename => @mission.title + ".zip"
        }
        )
      }
    end
  end
end