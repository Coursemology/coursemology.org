class Assessment::MissionSubmissionsController < Assessment::SubmissionsController
  # load_and_authorize_resource :submission, through: :assessment, class_name: "Assessment::Submission"
  # skip_load_and_authorize_resource :submission, only: :listall
  # skip_load_and_authorize_resource :mission, only: :listall

  # before_filter :authorize, only: [:new, :create, :edit, :update]
  # before_filter :allow_only_one_submission, only: [:new, :create]
  # before_filter :no_update_after_submission, only: [:edit, :update]


  def listall
    @tab = Mission

    @selected = {}
    # find selected assignment
    if params[:asm_id] && params[:asm_id] != "0"
      asm_id = params[:asm_id].to_i
      #selected_asm = @course.missions.find(asm_id)
      @selected[:asm] = @course.missions.find(asm_id)
    end

    # find selected students
    if params[:student] && params[:student] != "0"
      sc = params[:student].to_i
      @selected[:student] = @course.user_courses.find(sc)
    end

    if params[:tutor] && params[:tutor][0] != "0"
      tutor_id = params[:tutor][0].to_i
      @selected[:tutor] = @course.user_courses.find(tutor_id)
    end

    @all_asm = @course.missions
    @student_courses = @course.student_courses.order(:name)
    @staff_courses = @course.user_courses.staff

    if @selected[:asm]
      @sbms = @selected[:asm].sbms
    else
      @sbms = @course.submissions.includes(:mission).accessible_by(current_ability).order(:submit_at).reverse_order
    end

    if @selected[:student]
      @sbms = @sbms.where('std_course_id = ?', @selected[:student])
    elsif @selected[:tutor]

      students = @selected[:tutor].get_my_stds
      @sbms = @sbms.where(std_course_id:students)
    end

    @sbms = @sbms.where('status != ?','attempting')

    if curr_user_course.is_student?
      @sbms = @sbms.where("missions.publish =  1")
    end

    #@unseen = []
    #if curr_user_course.id
    #  @unseen = @sbms - curr_user_course.get_seen_sbms
    #  @unseen.each do |sbm|
    #    curr_user_course.mark_as_seen(sbm)
    #  end
    #end

    @sbms_paging = @course.mission_sbm_paging_pref
    if @sbms_paging.display?
      @sbms = @sbms.page(params[:page]).per(@sbms_paging.prefer_value.to_i)
    end
  end

  def show
    # if student is still attempting a mission, redirect to edit page
    if @submission.attempting? and @submission.std_course == curr_user_course
      redirect_to edit_course_mission_submission_path
      return
    end

    #if staff is accessing the submitted mission, redirect to grading page
    if (@submission.submitted? or @submission.graded?) and curr_user_course.is_staff?
      redirect_to new_course_assessment_submission_grading_path(@course, @assessment, @submission)
      return
    end

    if params[:grading_id]
      @grading = SubmissionGrading.find(grading_id)
    else
      @grading = @submission.gradings.last
    end
  end


  def create
    update
  end

  def edit
    @mission = @assessment.as_assessment
    @questions = @assessment.questions
    @submission.build_initial_answers
    # @std_answers = {}
    # @std_coding_answers = {}
    # @submission.std_answers.each { |answer| @std_answers[answer.question_id] = answer }
    # @submission.std_coding_answers.each { |answer| @std_coding_answers[answer.qn_id] = answer}
    respond_to do |format|
      format.html
    end
  end

  def update
    @submission.fetch_params_answers(params)
    if params[:files]
      @submission.attach_files(params[:files].values)
    end

    respond_to do |format|
      if @submission.save
        if params[:commit] == 'Save'
          @submission.set_attempting
          format.html { redirect_to edit_course_assessment_submission_path(@course, @assessment, @submission),
                                    notice: "Your submission has been saved." }
        else
          @submission.set_submitted(course_assessment_submission_url(@course, @assessment, @submission))
          format.html { redirect_to course_assessment_submission_path(@course, @assessment, @submission),
                                    notice: "Your submission has been updated." }
        end
      else
        format.html { render action: "edit" }
      end
    end
  end

  def unsubmit
    @submission.set_attempting
    flash[:notice] = "Successfully unsubmited submission."
    redirect_to course_mission_submission_path(@course, @mission, @submission)
  end

  def test_answer
    code = params[:code]
    std_answer = @submission.answers.where(id: params[:answer_id]).first
    if std_answer.attempt_left <= 0 and !curr_user_course.is_staff?
      result = {access_error: true, msg: "exceeds maximum testing times"}
    else
      # std_answer.attempt_left -= 1
      # std_answer.answer = code
      std_answer.save
      qn = std_answer.question
      combined_code = PythonEvaluator.combine_code(code, qn.specific.test_code)
      result = PythonEvaluator.eval_python(PythonEvaluator.get_asm_file_path(@assessment), combined_code, qn.specific, false)
    end
    result[:can_test] = std_answer.can_run_test? curr_user_course
    respond_to do |format|
      format.html {render json: result}
    end
  end

  private

  def allow_only_one_submission
    sub = @mission.submissions.where(std_course_id:curr_user_course.id).first
    if sub
      @submission = sub
    else
      @submission.std_course = curr_user_course
    end
    @submission.attempt_mission
  end

  def no_update_after_submission
    unless @submission.attempting?
      respond_to do |format|
        format.html { redirect_to course_mission_submission_path(@course, @mission, @submission),
                                  notice: "Your have already submitted this mission." }
      end
    end
  end

  def authorize
    if curr_user_course.is_staff?
      return true
    end

    can_start = @mission.can_start?(curr_user_course)
    unless can_start
      redirect_to course_mission_access_denied_path(@course, @mission)
    end
  end

end
