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

    @std_answers_for_questions = {}
    @training_submission.std_mcq_answers.each do |sma|
      mcq_id = sma.mcq_id
      if !@std_answers_for_questions.has_key?(mcq_id)
        @std_answers_for_questions[mcq_id] = []
      end
      @std_answers_for_questions[mcq_id] << sma
    end

    # one question can have many answers.
    # collect all answers of one question in a list
    # sort by order of created time
    @qadata.each do |qid, qa|
      if @std_answers_for_questions.has_key?(qid)
        @qadata[qid][:a] =
          @std_answers_for_questions[qid].sort_by(&:created_at).reverse
      end
    end

    if @grading
      @grading.answer_gradings.each do |ag|
        @qadata[ag.student_answer.mcq_id][:g] = ag
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
    # better experience => checking via. ajax
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

    sg = @training_submission.get_final_grading

    # currently, there is one answer grading for each question
    # when there are multiple answer for one question, it
    ag = nil
    sg.answer_gradings.each do |g|
      if g.student_answer.mcq == mcq
        ag = g
        break
      end
    end
    if !ag
      ag = sg.answer_gradings.build
    end
    if !ag.grade || ag.grade == 0 || mcqa.is_correct
      ag.student_answer = sma
      ag.grade = mcqa.is_correct ? mcq.max_grade : 0
      ag.save
    end

    mcq_pos = @training.get_qn_pos(mcq)
    puts mcq_pos, @training_submission.current_step
    if @training_submission.current_step == mcq_pos
      sbm_ans.is_final = true
      if mcqa.is_correct
        @training_submission.current_step = mcq_pos + 1
        # only update the grade if this is the latest question in student's path
        sg.total_grade += ag.grade
        sg.update_exp_transaction
        sg.save
      end
    end

    resp = {
      is_correct: mcqa.is_correct,
      result: mcqa.is_correct ? "True" : "False",
      explanation: mcqa.explanation
    }

    if @training_submission.save
      respond_to do |format|
        format.html { render json: resp }
      end
    end
  end
end
