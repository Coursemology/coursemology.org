class SubmissionsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :mission, through: :course
  load_and_authorize_resource :submission, through: :mission

  skip_load_and_authorize_resource :submission, only: :listall
  skip_load_and_authorize_resource :mission, only: :listall

  before_filter :authorize, only: [:new, :create, :edit, :update]
  before_filter :allow_only_one_submission, only: [:new, :create]
  before_filter :no_update_after_submission, only: [:edit, :update]
  before_filter :load_general_course_data, only: [:index, :listall, :show, :new, :create, :edit]


  def listall
    @tab = "MissionSubmission"

    # find selected assignment
    if params[:asm_id] && params[:asm_id] != "0"
      asm_id = params[:asm_id].to_i
      @selected_asm = @course.missions.find(asm_id)
    end

    # find selected students
    if params[:student] && params[:student] != "0"
      sc = params[:student].to_i
      @selected_sc = @course.user_courses.find(sc)
    end

    @all_asm = @course.missions
    @student_courses = @course.student_courses

    if @selected_asm
      @sbms = @selected_asm.sbms
    else
      @sbms = @course.submissions.accessible_by(current_ability).order(:submit_at).reverse_order
    end

    if @selected_sc
      @sbms = @sbms.where('std_course_id = ?', @selected_sc)
    end

    @sbms = @sbms.where('status != ?','attempting')

    @unseen = []
    if curr_user_course.id
      @unseen = @sbms - curr_user_course.get_seen_sbms
      @unseen.each do |sbm|
        curr_user_course.mark_as_seen(sbm)
      end
    end

    @sbms = @sbms.page(params[:page])

  end

  def show
    @qadata = {}

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
      format.html { render "submissions/show_question" }
    end
  end

  def new
    if @submission.save
      if @submission.attempt == 1 && curr_user_course.is_student?
        Activity.attempted_asm(curr_user_course, @mission)
      end
      respond_to do |format|
        format.html { redirect_to edit_course_mission_submission_path(@course,@mission,@submission)}
      end
    end
  end

  def create
    update
  end

  def edit
    @questions = @mission.get_all_questions
    @submission.build_initial_answers(current_user)
    @std_answers = {}
    @std_coding_answers = {}
    @submission.std_answers.each { |answer| @std_answers[answer.question_id] = answer }
    @submission.std_coding_answers.each { |answer| @std_coding_answers[answer.qn_id] = answer}
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

    if @mission.open_at > Time.now
      redirect_to course_mission_access_denied_path(@course, @mission)
    end
  end

end
