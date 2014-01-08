class MissionSubmissionsController < ApplicationController
  load_and_authorize_resource :course
  before_filter :load_resources
  load_and_authorize_resource :mission, through: :course
  load_and_authorize_resource :submission, through: :mission

  skip_load_and_authorize_resource :submission, only: :listall
  skip_load_and_authorize_resource :mission, only: :listall

  before_filter :authorize, only: [:new, :edit, :update]
  before_filter :allow_only_one_submission, only: [:new]
  before_filter :no_update_after_submission, only: [:edit, :update]
  before_filter :load_general_course_data, only: [:index, :listall, :show, :new, :edit]

  def listall
    @tab = "MissionSubmission"

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
      @sbms = @course.submissions.accessible_by(current_ability).order(:submit_at).reverse_order
    end

    if @selected[:student]
      @sbms = @sbms.where('std_course_id = ?', @selected[:student])
    elsif @selected[:tutor]

      students = @selected[:tutor].get_my_stds
      @sbms = @sbms.where(std_course_id:students)
    end

    @sbms = @sbms.where('status != ?','attempting')

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
    @qadata = {}
    # if student is still attempting a mission, redirect to edit page
    if @submission.attempting? and @submission.std_course == curr_user_course
      redirect_to edit_course_mission_submission_path
      return
    end

    #if staff is accessing the submitted mission, redirect to grading page
    if (@submission.submitted? or @submission.graded?) and curr_user_course.is_staff?
      redirect_to new_course_mission_submission_submission_grading_path(@course, @mission, @submission)
      return
    end

    if params[:grading_id]
      @grading = SubmissionGrading.find(grading_id)
    else
      @grading = @submission.final_grading
    end

    @mission.get_all_questions.each_with_index do |q,i|
      @qadata[q.id.to_s+q.class.to_s] = { q: q, i: i + 1 }
    end

    @submission.get_all_answers.each do |sa|
      qn = sa.qn
      @qadata[qn.id.to_s + qn.class.to_s][:a] = sa
    end

    if @grading
      @grading.answer_gradings.each do |ag|
        qn = ag.student_answer.qn
        @qadata[qn.id.to_s + qn.class.to_s][:g] = ag
      end
    end

    respond_to do |format|
      format.html { render 'show_question' }
    end
  end

  def new
    @submission.std_course = curr_user_course
    @submission.assessment = @mission.assessment
    @submission.set_attempting
    @submission.save!

    # Update the activity feed. We cannot arrive here if the student already has a submission.
    if curr_user_course.is_student?
      Activity.attempted_asm(curr_user_course, @mission)
    end

    respond_to do |format|
      format.html { redirect_to edit_course_assessment_mission_assessment_submission_path(@course, @mission, @submission) }
    end
  end

  def edit
    @questions = @mission.get_all_questions
    @submission.build_initial_answers

    respond_to do |format|
      format.html
    end
  end

  def update
    @submission.fetch_params_answers(params,current_user)
    if params[:files]
      @submission.attach_files(params[:files].values)
    end

    respond_to do |format|
      if @submission.save
        if params[:commit] == 'Save'
          @submission.set_attempting
          format.html { redirect_to edit_course_mission_submission_path(@course, @mission, @submission),
                                    notice: "Your submission has been saved." }
        else
          @submission.set_submitted(course_mission_submission_url(@course,@mission,@submission))
          eval_answer
          format.html { redirect_to course_mission_submission_path(@course, @mission, @submission),
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
    std_answer = @submission.std_coding_answers.where(id: params[:answer_id]).first
    if std_answer.test_left == 0
      result = {access_error: "exceeds maximum testing times"}
    else
      std_answer.test_left -= 1
      std_answer.code = code
      std_answer.save
      qn = std_answer.qn
      combined_code = PythonEvaluator.combine_code(code, qn.test_code)
      result = PythonEvaluator.eval_python(PythonEvaluator.get_asm_file_path(@mission), combined_code, qn.data_hash, true)
    end

    respond_to do |format|
      format.html {render json: result}
    end
  end

  def eval_answer
    Thread.start {
      @submission.std_coding_answers.each do |answer|
        qn = answer.qn
        unless qn.is_auto_grading?
          next
        end
        combined_code = PythonEvaluator.combine_code(answer.code, qn.test_code)
        result = PythonEvaluator.eval_python(PythonEvaluator.get_asm_file_path(@mission), combined_code, qn.data_hash, true)
        answer.result = result.to_json
        answer.save
      end
    }
  end

private
  def load_resources
    @mission = Assessment::Mission.find(params[:assessment_mission_id])
    @submission = case params[:action]
                    when 'new'
                      Assessment::Submission.new
                    when 'create'
                      q = Assessment::Submission.new
                      q.attributes = params[:assessment_submission]
                      q
                    else
                      Assessment::Submission.find_by_id!(params[:id])
                  end
  end

  def allow_only_one_submission
    sub = @mission.submissions.where(std_course_id:curr_user_course.id).first
    redirect_to course_assessment_mission_assessment_submission_path(@course, @mission, sub) and return if sub
  end

  def no_update_after_submission
    unless @submission.attempting?
      respond_to do |format|
        format.html { redirect_to course_assessment_mission_assessment_submission_path(@course, @mission, @submission),
                                  notice: 'You have already submitted this mission.' }
      end
    end
  end

  def authorize
    if curr_user_course.is_staff?
      return true
    end

    can_start = @mission.can_start?(curr_user_course).first
    unless can_start
      redirect_to course_mission_access_denied_path(@course, @mission)
    end
  end
end
