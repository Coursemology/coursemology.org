class MissionsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :mission, through: :course, class: 'Assessment::Mission'

  before_filter :load_general_course_data, only: [:show, :index, :new, :edit, :access_denied, :stats, :overview]

  require 'zip/zipfilesystem'

  def index
    @is_new = {}
    @tags_map = {}
    @selected_tags = params[:tags]
    @display_columns = {}
    @course.mission_columns_display.each do |cp|
      @display_columns[cp.preferable_item.name] = cp.prefer_value
    end
    @time_format =  @course.mission_time_format

    @missions = @course.missions.accessible_by(current_ability)
    @paging = @course.missions_paging_pref


    if @selected_tags
      tags = Tag.find(@selected_tags)
      mission_ids = tags.map { |tag| tag.missions.map{ |t| t.id } }.reduce(:&)
      @missions = @missions.where(id: mission_ids).accessible_by(current_ability)
      tags.each { |tag| @tags_map[tag.id] = true }
    end

    if @paging.display?
      @missions = @missions.order('assessment_assessments.open_at').page(params[:page]).per(@paging.prefer_value.to_i)
    end

    if curr_user_course.id
      unseen = @missions - curr_user_course.seen_missions
      unseen.each do |um|
        @is_new[um.id] = true
        curr_user_course.mark_as_seen(um)
      end
    end
    respond_to do |format|
      format.html
    end
  end

  def show
    if curr_user_course.is_student? and !@mission.can_start?(curr_user_course).first
      redirect_to course_assessment_missions_path and return
    end

    @mission = @mission.specific
    @questions = @mission.questions.map { |q| q.specific }
    @question = Assessment::TextQuestion.new
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
    @mission.tags.each { |asm_tag| @asm_tags[asm_tag.id] = true }
  end

  def create
    @missions = @course.missions
    @mission.course = @course
    @mission.creator = current_user
    @mission.pos = @course.missions.count + 1
    @mission.update_tags(params[:tags])

    if params[:files]
      @mission.attach_files(params[:files].values)
    end
    # TODO: Implement or remove
    if @mission.single_question?
      qn = params[:answer_type] == 'code' ? @mission.coding_questions.build : @mission.questions.build
      qn.max_grade = params[:max_grade]
    end

    respond_to do |format|
      if @mission.save
        @mission.schedule_mail(@course.user_courses, course_assessment_mission_url(@course, @mission))
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
      if @mission.update_attributes(params[:assessment_mission])

        # TODO: Implement or Remove
        if @mission.single_question? && @mission.get_all_questions.count > 1
          flash[:error] = "Mission already have several questions, can't change the format."
          @mission.single_question = false
          @mission.save
        end
        update_single_question_type

        @mission.schedule_mail(@course.user_courses, course_assessment_mission_url(@course, @mission))
        format.html { redirect_to course_assessment_mission_path(@course, @mission),
                                  notice: "The mission #{@mission.title} has been updated." }
      else
        format.html { redirect_to edit_course_assessment_mission_path(@course, @mission) }
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

  def update_single_question_type
    return
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
    @display_columns = {}
    @course.mission_columns_display.each do |cp|
      @display_columns[cp.preferable_item.name] = cp.prefer_value
    end

    @missions = @course.missions.accessible_by(current_ability).order(:open_at)
    @missions = @missions.map { |m| m.specific }
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

    temp_folder = "#{Rails.root}/paths/tmp/"

    t = Tempfile.new("my-temp-filename-#{Time.now}")

    Zip::ZipOutputStream.open(t.path) do |z|
      sbms.each do |sbm|
        ans = sbm.std_coding_answers.first
        unless ans
          next
        end
        #TODO: hardcoded
        #title = "#{ sbm.std_course.name.gsub(/\//,"_") } - #{@mission.title.gsub(/\//,"_") }.py"
        #only student name
        title = "#{ sbm.std_course.name.gsub(/\//,"_") }.py"
        file = File.open(temp_folder + title, 'w+')
        file.write(ans.code)
        file.close

        z.put_next_entry(title)
        z.print IO.read(file.path)
        File.delete(file.path)
      end
    end

    file_upload = FileUpload.create({
                                        creator: current_user,
                                        owner: @course,
                                        file: t
                                    })
    t.close
    if file_upload.save
      respond_to do |format|
        format.json {render json: {file_name: @mission.title + ".zip", file_url: file_upload.file_url} }
      end
    end
  end
end