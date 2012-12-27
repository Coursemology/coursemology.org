class QuizSubmissionsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :quiz, through: :course
  load_and_authorize_resource :quiz_submission, through: :quiz

  skip_load_and_authorize_resource :quiz_submission, only: :listall
  skip_load_and_authorize_resource :quiz, only: :listall

  def index
  end

  def listall
    if params.has_key?(:student_id)
      @quiz_submissions = QuizSubmission.all_student(@course, current_user)
    else
      puts @course.to_json
      @quiz_submissions = QuizSubmission.all_course(@course)
    end
    puts @quiz_submissions.to_json
  end

  def show
    @qadata = {}

    if params[:grading_id]
      @grading = SubmissionGrading.find(grading_id)
    else
      @grading = @quiz_submission.final_grading
    end

    @quiz.mcqs.each do |mcq|
      @qadata[mcq.id] = { q: mcq }
    end

    @quiz_submission.std_mcq_answers.each do |sma|
      @qadata[sma.mcq.id][:a] = sma
    end

    if @grading
      @grading.answer_gradings.each do |ag|
        @qadata[ag.student_answer.mcq_id][:g] = ag
      end
    end

    puts @qadata

    respond_to do |format|
      format.html { render "quiz_submissions/show_mcq" }
    end
  end

  def new
    @mcqs = @quiz.mcqs
    respond_to do |format|
      format.html
    end
  end

  def create
    @quiz_submission.student_id = current_user.id

    sg = SubmissionGrading.new
    sg.sbm = @quiz_submission
    puts "build submission grading"
    total_grade = 0
    params[:answers].each do |qid, ansid|
      @mcq = Mcq.find(qid)
      @answer = McqAnswer.find(ansid)

      sma = @quiz_submission.std_mcq_answers.build({
        mcq_answer_id: ansid
      })
      sma.mcq = @mcq

      grade = @answer.is_correct ? @mcq.max_grade : 0
      ag = sg.answer_gradings.build({
        grade: grade
      })
      ag.student_answer = sma
      total_grade += grade
    end

    sg.total_grade = total_grade
    sg.update_exp_transaction # this is not triggered automatically on association
    @quiz_submission.final_grading = sg

    if @quiz_submission.save
      respond_to do |format|
        format.html
      end
    else
      respond_to do |format|
        format.html { render action: "new" }
      end
    end
  end


end
