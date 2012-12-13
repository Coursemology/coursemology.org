class SubmissionsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :assignment, through: :course
  load_and_authorize_resource :submission, through: :assignment

  skip_load_and_authorize_resource :submission, only: :listall
  skip_load_and_authorize_resource :assignment, only: :listall

  def index
  end

  def listall
    if params.has_key?(:student_id)
      @submissions = Submission.all_student(@course, current_user)
    else
      puts @course.to_json
      @submissions = Submission.all_course(@course)
    end
  end

  def show
    # has submission, has assignment, has student answers
    # add grading report
    @qadata = {}

    if params[:grading_id]
      @grading = SubmissionGrading.find(grading_id)
    else
      @grading = @submission.final_grading
    end

    if @assignment.auto_graded > 0
      template = "submissions/show_mcq"
      @assignment.mcqs.each do |mcq|
        @qadata[mcq.id] = { q: mcq }
      end
      @submission.std_mcq_answers.each do |sma|
        @qadata[sma.mcq.id][:a] = sma
      end
      if @grading
        @grading.answer_gradings.each do |ag|
          @qadata[ag.student_answer.mcq_id][:g] = ag
        end
      end
    else
      template = "submissions/show_question"
      @assignment.questions.each do |q|
        @qadata[q.id] = { q: q }
      end
      @submission.std_answers.each do |sa|
        @qadata[sa.question.id][:a] = sa
      end
      if @grading
        @grading.answer_gradings.each do |ag|
          @qadata[ag.student_answer.question_id][:g] = ag
        end
      end
    end

    puts @qadata

    respond_to do |format|
      format.html { render :template => template }
    end
  end

  def new
    @mcqs = @assignment.mcqs
    @questions = @assignment.questions
    respond_to do |format|
      format.html
    end
  end

  def create
    @submission.student_id = current_user.id
    if params[:auto_graded].to_f > 0
      sg = @submission.submission_gradings.build({
      })
      total_grade = 0
      params[:answers].each do |qid, ansid|
        @mcq = Mcq.find(qid)
        @answer = McqAnswer.find(ansid)

        sma = @submission.std_mcq_answers.build({
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
      @submission.final_grading = sg
    else
      params[:answers].each do |qid, ans|
        @wq = Question.find(qid)
        sa = @submission.std_answers.build({
          text: ans,
        })
        sa.question = @wq
      end
    end
    if @submission.save
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
