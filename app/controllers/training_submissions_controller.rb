class TrainingSubmissionsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :training, through: :course
  load_and_authorize_resource :training_submission, through: :training

  def index
  end

  def show
    # showing all the answers up to now, by question, in reverse order of time
  end

  def new
    @training_submission.student = current_user
    @training_submission.training = @training
    @training_submission.open_at = DateTime.now
    @training_submission.current_step = 1
    @training_submission.save

    sg = SubmissionGrading.new
    sg.sbm = @training_submission
    sg.total_grade = 0
    sg.save

    respond_to do |format|
      format.html do
        redirect_to edit_course_training_training_submission_path(@course,
            @training, @training_submission)
      end
    end
  end

  def edit
    @step = @training_submission.current_step
    if params[:step] && params[:step].to_i >= 1
      @step = [@step, params[:step].to_i].min
    end
    puts @training.mcqs.to_json
    if @step <= @training.mcqs.size
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

    sg = @training_submission.submission_grading
    ag = sg.answer_gradings.build
    ag.student_answer = sma
    ag.grade = mcqa.is_correct ? mcq.max_grade : 0
    ag.submission_grading = sg

    mcq_pos = @training.get_qn_pos(mcq)
    puts mcq_pos, @training_submission.current_step
    if @training_submission.current_step == mcq_pos
      sbm_ans.is_final = true
      if mcqa.is_correct
        @training_submission.current_step = mcq_pos + 1
        # only update the grade if this is the latest question in student's path
        puts 'sub grading ', sg.to_json
        sg.total_grade += ag.grade
        sg.update_exp_transaction
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
