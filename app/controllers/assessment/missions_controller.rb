class Assessment::MissionsController < Assessment::AssessmentsController
  load_and_authorize_resource :mission, class: "Assessment::Mission", through: :course

  require 'zip/zipfilesystem'

  def show
    if curr_user_course.is_student? and !@assessment.can_start?(curr_user_course)
      redirect_to course_assessment_missions_path
      return
    end
    @assessment = @mission.assessment
    super

    @summary[:allowed_questions] = [Assessment::GeneralQuestion, Assessment::CodingQuestion]
    @summary[:type] = 'mission'

    respond_to do |format|
      format.html { render "assessment/assessments/show" }
    end
  end

  def new
    @missions = @course.missions
    @mission.exp = 1000
    @mission.open_at = DateTime.now.beginning_of_day
    @mission.close_at = DateTime.now.end_of_day + 7  # 1 week from now
    @mission.course_id = @course.id

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
    # @mission.asm_tags.each { |asm_tag| @asm_tags[asm_tag.tag_id] = true }
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
      if @mission.update_attributes(params[:assessment_mission])

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
    authorize! :bulk_update, Assessment
    @tab = 'overview'
    @display_columns = {}
    @course.mission_columns_display.each do |cp|
      @display_columns[cp.preferable_item.name] = cp.prefer_value
    end

    @missions = @course.missions.accessible_by(current_ability).order(:open_at)
  end

  def bulk_update
    authorize! :bulk_update, Assessment
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