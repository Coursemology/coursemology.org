class Assessment::MissionSubmissionsController < Assessment::SubmissionsController
  before_filter :authorize, only: [:new, :create, :edit, :update]
  before_filter :no_update_after_submission, only: [:edit, :update]

  def show
    # if student is still attempting a mission, redirect to edit page
    if @submission.attempting? and @submission.std_course == curr_user_course
      redirect_to edit_course_assessment_submission_path(@course, @assessment, @submission)
      return
    end

    #if staff is accessing the submitted mission, redirect to grading page
    if curr_user_course.is_staff? and (@submission.submitted? or @submission.graded?)
        redirect_to new_course_assessment_submission_grading_path(@course, @assessment, @submission)
      return
    end

    if @submission.graded?
      grading = @submission.gradings.first
      redirect_to course_assessment_submission_grading_path(@course, @assessment, @submission,grading)
    end
  end


  def create
    update
  end

  def edit
    @mission = @assessment.as_assessment
    @questions = @assessment.questions
    @submission.build_initial_answers
  end

  def update
    @submission.fetch_params_answers(params)
    if params[:files]
      @submission.attach_files(params[:files].values)
    end

    if params[:commit] == 'Save'
      @submission.saved_at = Time.now
    end

    respond_to do |format|
      if @submission.save
        if params[:commit] == 'Save'
          @submission.set_attempting
          format.html { redirect_to edit_course_assessment_submission_path(@course, @assessment, @submission),
                                    notice: "Your submission has been saved." }
        else
          @submission.set_submitted
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
    redirect_to course_assessment_submission_path(@course, @assessment, @submission)
  end

  def test_answer
    code = params[:code]
    std_answer = @submission.answers.where(id: params[:answer_id]).first
    if std_answer.attempt_left <= 0 and !curr_user_course.is_staff?
      result = {access_error: true, msg: "exceeds maximum testing times"}
    else
      std_answer.attempt_left -= 1
      std_answer.content = code
      std_answer.save
      qn = std_answer.question
      combined_code = PythonEvaluator.combine_code([qn.pre_include, std_answer.content, qn.append_code])
      result = PythonEvaluator.eval_python(PythonEvaluator.get_asm_file_path(@assessment), combined_code, qn.specific, false)

      set_hints(result, qn)
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
        format.html { redirect_to course_assessment_submission_path(@course, @assessment, @submission),
                                  notice: "Your have already submitted this mission." }
      end
    end
  end

  def authorize
    if curr_user_course.is_staff?
      return true
    end

    can_start = @assessment.can_start?(curr_user_course)
    unless can_start
      redirect_to access_denied_course_assessment_path(@course, @assessment)
    end
  end

end
