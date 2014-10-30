class Assessment::MissionsController < Assessment::AssessmentsController
  load_and_authorize_resource :mission, class: "Assessment::Mission", through: :course

  require 'zip/zipfilesystem'

  def show
    @assessment = @mission.assessment
    if curr_user_course.is_student? and !@assessment.can_start?(curr_user_course)
      redirect_to course_assessment_missions_path
      return
    end
    super
    @summary[:allowed_questions] = [Assessment::GeneralQuestion, Assessment::CodingQuestion]
    @summary[:type] = 'mission'
    @summary[:specific] = @mission

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
  end

  def create
    @missions = @course.missions
    @mission.position = @course.missions.count + 1
    @mission.creator = current_user
    @mission.course_id = @course.id
    if params[:files]
      @mission.attach_files(params[:files].values)
    end

    if params[:single_question].to_i == 1
      if params[:answer_type] == 'code'
        specific = Assessment::CodingQuestion.new
      else
        specific = Assessment::GeneralQuestion.new
      end
      qn = @mission.questions.build
      qn.creator = current_user
      qn.max_grade = params[:max_grade]
      specific.question = qn
      specific.save
    end

    if params[:assessment_mission][:dependent_on_attributes]
      @mission.dependent_on_ids = params[:assessment_mission][:dependent_on_attributes].values.select {|t| t[:_destroy] == "false"}.collect {|t| t[:dependent_on_ids]}
    end
    params[:assessment_mission].delete(:dependent_on_attributes)

    respond_to do |format|
      if @mission.save
        @mission.create_local_file
        format.html { redirect_to course_assessment_mission_path(@course, @mission),
                                  notice: "The mission #{@mission.title} has been created." }
      else
        format.html { render action: "new" }
      end
    end
  end

  def update

    if params[:assessment_mission][:dependent_on_attributes]
      params[:assessment_mission][:dependent_on_ids] = params[:assessment_mission][:dependent_on_attributes].values.select {|t| t[:_destroy] == "false"}.collect {|t| t[:dependent_on_ids]}
    end
    params[:assessment_mission].delete(:dependent_on_attributes)

    respond_to do |format|
      if @mission.update_attributes(params[:assessment_mission])
        update_single_question_type
        format.html { redirect_to course_assessment_mission_path(@course, @mission),
                                  notice: "The mission #{@mission.title} has been updated." }
      else
        format.html {redirect_to edit_course_assessment_mission_path(@course, @mission) }
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
    unless @mission.single_question?
      return
    end

    type = params[:answer_type] == 'code' ? Assessment::CodingQuestion : Assessment::GeneralQuestion
    curr_qn = @mission.questions.first
    if type != curr_qn.specific.class
      if curr_qn
        curr_qn.destroy
      end
      if params[:answer_type] == 'code'
        specific = Assessment::CodingQuestion.new
      else
        specific = Assessment::GeneralQuestion.new
      end
      qn = @mission.questions.create({creator_id: current_user.id, max_grade: params[:max_grade]})
      specific.question = qn
      specific.save
    else
      curr_qn.max_grade = params[:max_grade]
      curr_qn.save
    end

    @mission.save
  end

  def bulk_update
    super
    redirect_to overview_course_assessment_missions_path
  end

  def dump_code
    @mission = @course.missions.find(params[:assessment_mission_id])
    case params[:_type]
      when 'My'
        std_courses =  curr_user_course.std_courses
      when 'Phantom'
        std_courses = @course.user_courses.student.where(is_phantom: true)
      else
        std_courses = @course.user_courses.student.where(is_phantom: false)
    end

    sbms = @mission.submissions.
        where("std_course_id IN (?) and status = 'graded'", std_courses.select("user_courses.id")).includes(:coding_answers)

    result = nil

    Dir.mktmpdir("mission-dump-temp-#{Time.now}") { |dir|
      sbms.each do |sbm|
        ans = sbm.coding_answers.first
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
        file.write(ans.content)
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

  def access_denied
    respond_to   do |format|
      format.html # show.html.erb
    end
  end

end