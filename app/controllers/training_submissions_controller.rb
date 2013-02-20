class TrainingSubmissionsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :training, through: :course
  load_and_authorize_resource :training_submission, through: :training

  before_filter :load_general_course_data, only: [:show, :index, :edit]

  def index
  end

  def show
    @qadata = {}
    @grading = @training_submission.get_final_grading
    @training.mcqs.each_with_index do |mcq, index|
      break if @training_submission.current_step - 1 <= index
      @qadata[mcq.id] = { q: mcq }
    end

    @std_answers_for_questions = Hash.new{ |h, k| h[k] = [] }
    @training_submission.std_mcq_answers.each do |sma|
      mcq_id = sma.mcq_id
      @std_answers_for_questions[mcq_id] << sma
    end
    # puts '==='
    # puts @training.to_json
    # puts @training_submission.to_json
    # puts @grading.to_json
    # puts @training_submission.std_mcq_answers.to_json
    # puts @std_answers_for_questions.to_json

    # one question can have many answers.
    # collect all answers of one question in a list
    # sort by order of created time
    @qadata.each do |qid, qa|
      if @std_answers_for_questions.has_key?(qid)
        @qadata[qid][:a] = @std_answers_for_questions[qid].sort_by(&:created_at)
      end
    end

    if @grading
      @grading.answer_gradings.each do |ag|
        if ag.student_answer && @qadata.has_key?(ag.student_answer.mcq_id)
          @qadata[ag.student_answer.mcq_id][:g] = ag
        end
      end
    end

    puts @qadata
  end

  def new
    @training_submission.std_course = curr_user_course
    @training_submission.training = @training
    @training_submission.open_at = DateTime.now
    @training_submission.current_step = 1
    @training_submission.save

    @course.lect_courses.each do |uc|
      UserMailer.new_submission(
        uc.user,
        course_training_training_submission_url(@course, @training, @training_submission)
      ).deliver
    end

    Activity.started_asm(curr_user_course, @training)

    sg = SubmissionGrading.new
    sg.sbm = @training_submission
    sg.total_grade = 0
    sg.save

    respond_to do |format|
      format.html do
        redirect_to edit_course_training_training_submission_path(
            @course, @training, @training_submission)
      end
    end
  end

  def edit
    @current_step = @training_submission.current_step
    @step = @current_step
    @max_step = @training.mcqs.count
    if params[:step] && params[:step].to_i >= 1
      @step = [@step, params[:step].to_i].min
    end
    if @step <= @max_step
      @current_mcq = @training.mcqs[@step - 1]
    end
    respond_to do |format|
      format.html { render template: "training_submissions/do.html.erb" }
    end
  end

  def submit
    # what's the current question?
    # correct? => render continue
    # incorrect? => render the same one, with message showing what is wrong
    puts 'Update', params, current_user.to_json
    mcq = Mcq.find(params[:qid])
    mcqa = McqAnswer.find(params[:aid])
    sma = StdMcqAnswer.new()
    sma.student = current_user
    sma.mcq = mcq
    sma.mcq_answer = mcqa
    # TODO: record the choices

    sbm_ans = @training_submission.sbm_answers.build
    sbm_ans.answer = sma

    mcq_pos = @training.get_qn_pos(mcq)
    grade = 0
    if @training_submission.current_step == mcq_pos
      if mcqa.is_correct
        @training_submission.current_step = mcq_pos + 1
        grade = @training_submission.auto_grade(mcq, sbm_ans)
      end
    end

    grade_str = grade > 0 ? " + #{grade}" : ""
    resp = {
      is_correct: mcqa.is_correct,
      result: mcqa.is_correct ? "Correct! #{grade_str}" : "Incorrect!",
      explanation: mcqa.explanation
    }

    if @training_submission.save
      respond_to do |format|
        format.html { render json: resp }
      end
    end
  end
end
