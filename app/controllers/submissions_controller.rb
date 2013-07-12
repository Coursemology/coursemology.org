class SubmissionsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :mission, through: :course
  load_and_authorize_resource :submission, through: :mission

  skip_load_and_authorize_resource :submission, only: :listall
  skip_load_and_authorize_resource :mission, only: :listall

  before_filter :load_general_course_data, only: [:index, :listall, :show, :new, :create]

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
      @sbms = @course.submissions.accessible_by(current_ability).order(:created_at).reverse_order
    end

    if @selected_sc
      @sbms = @sbms.where('std_course_id = ?', @selected_sc)
    end

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

    @mission.questions.each_with_index do |q, i|
      @qadata[q.id] = { q: q, i: i + 1 }
    end

    @submission.std_answers.each do |sa|
      @qadata[sa.question.id][:a] = sa
    end

    if @grading
      @grading.answer_gradings.each do |ag|
        @qadata[ag.student_answer.question_id][:g] = ag
      end
    end

    puts @qadata

    respond_to do |format|
      format.html { render "submissions/show_question" }
    end
  end

  def new
    @questions = @mission.questions
    respond_to do |format|
      format.html
    end
  end

  def create
    @submission.std_course = curr_user_course
    params[:answers].each do |qid, ans|
      @wq = Question.find(qid)
      sa = @submission.std_answers.build({
        text: ans,
      })
      sa.question = @wq
      sa.student = current_user
    end
    if @submission.save
      Activity.attempted_asm(curr_user_course, @mission)
      curr_user_course.get_my_tutors.each do |uc|
        puts 'notify tutors'
        UserMailer.delay.new_submission(
            uc.user,
            new_course_mission_submission_submission_grading_url(@course, @mission, @submission)
        )
      end
      respond_to do |format|
        format.html { redirect_to course_submissions_url(@course),
                      notice: "Your submission has been recorded." }
      end
    else
      respond_to do |format|
        format.html { render action: "new" }
      end
    end
  end
end
