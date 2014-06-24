
class TrainingSubmissionsController < ApplicationController
  include TrainingSubmissionsHelper
  load_and_authorize_resource :course
  load_and_authorize_resource :training, through: :course
  load_and_authorize_resource :training_submission, through: :training

  skip_load_and_authorize_resource :training_submission, only: :listall
  skip_load_and_authorize_resource :training, only: :listall

  before_filter :authorize, only: [:new, :edit]
  before_filter :load_general_course_data, only: [:show, :edit, :listall]

  def listall
    @tab = Training


    @selected = {}
    # find selected assignment
    if params[:asm_id] && params[:asm_id] != "0"
      asm_id = params[:asm_id].to_i
      @selected[:asm] = @course.trainings.find(asm_id)
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

    @all_asm = @course.trainings
    @student_courses = @course.student_courses.order(:name)
    @staff_courses = @course.user_courses.staff

    if @selected[:asm]
      @sbms = @selected[:asm].sbms
    else
      @sbms = @course.training_submissions.accessible_by(current_ability).order(:created_at).reverse_order
    end

    if @selected[:student]
      @sbms = @sbms.where('std_course_id = ?', @selected[:student])
    elsif @selected[:tutor]

      students = @selected[:tutor].get_my_stds
      @sbms = @sbms.where(std_course_id:students)
    end

    #@unseen = []
    #if curr_user_course.id
    #  @unseen = @sbms - curr_user_course.get_seen_sbms
    #  @unseen.each do |sbm|
    #    curr_user_course.mark_as_seen(sbm)
    #  end
    #end

    @sbms_paging = @course.training_sbm_paging_pref
    if @sbms_paging.display?
      @sbms = @sbms.page(params[:page]).per(@sbms_paging.prefer_value.to_i)
    end


    respond_to do |format|
      format.html { render "mission_submissions/listall" }
    end
  end

  #@mission.get_all_questions.each_with_index do |q,i|
  #  @qadata[q.id.to_s+q.class.to_s] = { q: q, i: i + 1 }
  #end
  #
  #@submission.get_all_answers.each do |sa|
  #  qn = sa.qn
  #  @qadata[qn.id.to_s + qn.class.to_s][:a] = sa
  #end
  #
  #if @grading
  #  @grading.answer_gradings.each do |ag|
  #    qn = ag.student_answer.qn
  #    @qadata[qn.id.to_s + qn.class.to_s][:g] = ag
  #  end
  #end

  def show
    @qadata = {}
    @grading = @training_submission.get_final_grading
    @training.questions.each_with_index do |qn, index|
      break if @training_submission.current_step <= index && !@training.can_skip?
      @qadata[qn.id.to_s+qn.class.to_s] = {q: qn}
    end

    @std_answers_for_questions =  Hash.new{ |h, k| h[k] = [] }
    @training_submission.get_all_answers.each do |sma|
      @std_answers_for_questions[sma.qn_id.to_s + sma.qn.class.to_s] << sma
    end

    @qadata.each do |qid, qa|
      if @std_answers_for_questions.has_key?(qid)
        @qadata[qid][:a] = @std_answers_for_questions[qid].sort_by(&:created_at)
      end
    end

    if @grading
      @grading.answer_gradings.each do |ag|
        if (sta = ag.student_answer) and sta.qn
          @qadata[sta.qn_id.to_s + sta.qn.class.to_s][:g] = ag
        end
      end
    end
  end

  def new

    @reattempt = @course.course_preferences.training_reattempt.first
    sbm = @training.training_submissions.where(std_course_id: curr_user_course).last
    if sbm && (!@reattempt || !@reattempt.display)
      sbm = @training.training_submissions.where(std_course_id: curr_user_course).last
      redirect_to edit_course_assessment_training_training_submission_path(@course, @training, sbm)
      return
    end

    @training_submission.std_course = curr_user_course
    @training_submission.training = @training
    @training_submission.open_at = DateTime.now
    @training_submission.current_step = 1

    # Is it the first submission? Otherwise set the multiplier to 1/5
    sbm_count = @training.training_submissions.where(std_course_id: curr_user_course).count
    if sbm_count > 0
      @training_submission.multiplier = @reattempt.prefer_value.to_f / 100
    end

    @training_submission.save

    #@course.lect_courses.each do |uc|
    #  UserMailer.delay.new_submission(
    #      uc.user,
    #      course_assessment_training_training_submission_url(@course, @training, @training_submission)
    #  )
    #end
    if curr_user_course.is_student? && sbm_count == 0
      Activity.started_asm(curr_user_course, @training)
    end

    sg = SubmissionGrading.new
    sg.sbm = @training_submission
    sg.total_grade = 0
    sg.save

    respond_to do |format|
      format.html do
        redirect_to edit_course_assessment_training_training_submission_path(
                        @course, @training, @training_submission)
      end
    end
  end

  def edit
    @current_step = @training_submission.current_step
    @step = @current_step
    @max_step = @training.questions.count

    #staff can skip steps
    if params[:step] && params[:step].to_i >= 1
      @step = (curr_user_course.is_staff? || @training.can_skip?) ? params[:step].to_i : [@step, params[:step].to_i].min
    end

    if @step <= @max_step
      @current_question = @training.questions[@step - 1]
    elsif (left = @training_submission.questions_left).length > 0
      @step = @training.questions.index(left.first) + 1
      @current_question = left.first
    end

    if @current_question.class == CodingQuestion
      @prefilled_code = @current_question.data_hash["prefill"]
      if @current_question.include_sol_qn
        std_answer = @current_question.include_sol_qn.std_coding_answers.where("is_correct is TRUE AND std_course_id = ?", curr_user_course.id).last
        code = std_answer ? std_answer.code : ""
        @prefilled_code = "#Answer from your previous question \n" + code + (@prefilled_code.empty? ? "" : ("\n\n#prefilled code \n" + @prefilled_code))

      end
    end

    respond_to do |format|
      format.html { render template: "training_submissions/do.html.erb" }
    end
  end

  def submit
    # what's the current question?
    # correct? => render continue
    # incorrect? => render the same one, with message showing what is wrong
    @current_question = @training.questions[params[:current_step].to_i - 1]

    if @current_question.class == Mcq
      if @current_question.select_all
        submit_mcq_select_all()
      else
        submit_mcq()
      end
    else
      submit_code()
    end

  end

  def submit_mcq
    require_dependency 'auto_grader'

    mcq = Mcq.find(params[:qid])
    mcqa = McqAnswer.find(params[:aid].first)
    sma = StdMcqAnswer.new()
    sma.student = current_user
    sma.std_course = curr_user_course
    sma.mcq = mcq
    sma.mcq_answer = mcqa
    # TODO: record the choices

    puts mcqa.to_json

    sbm_ans = @training_submission.sbm_answers.build
    sbm_ans.answer = sma

    mcq_pos = @training.get_qn_pos(mcq)
    is_correct = false
    grade = 0

    pref_grader = @course.mcq_auto_grader.prefer_value
    if pref_grader == 'two-one-zero'
      is_correct, grade = AutoGrader.toz_mcq_grader(@training_submission, mcq, sbm_ans)
    else
      is_correct, grade = AutoGrader.mcq_grader(@training_submission, mcq, sbm_ans)
    end

    if is_correct && !@training_submission.graded?
      @training_submission.current_step = mcq_pos + 1
      if @training_submission.done?
        @training_submission.update_grade
      end
    end

    grade_str = grade > 0 ? " + #{grade}" : ""

    if pref_grader == 'two-one-zero'
      correct_str =  "Correct! #{grade_str}"
    else
      correct_str =  "Correct!"
    end
    resp = {
        is_correct: mcqa.is_correct,
        result: mcqa.is_correct ? correct_str : "Incorrect!",
        explanation: mcqa.explanation
    }

    if @training_submission.save
      respond_to do |format|
        format.html { render json: resp }
      end
    end
  end

  def submit_mcq_select_all
    require_dependency 'auto_grader'

    mcq = Mcq.find(params[:qid])
    answers = params[:aid].map(&:to_i).to_json
    sma = StdMcqAllAnswer.new()
    sma.student = current_user
    sma.std_course = curr_user_course
    sma.mcq = mcq
    sma.selected_choices = answers
    sma.choices = params[:choices].map(&:to_i).to_json
    mcqas = McqAnswer.where(id: eval(answers))

    sbm_ans = @training_submission.sbm_answers.build
    sbm_ans.answer = sma
    mcq_pos = @training.get_qn_pos(mcq)

    if @course.mcq_auto_grader.prefer_value == 'two-one-zero'
      is_correct, grade = AutoGrader.toz_mcq_select_all_grader(@training_submission, mcq, sbm_ans)
    else
      is_correct, grade = AutoGrader.mcq_select_all_grader(@training_submission, mcq, sbm_ans)
    end

    if is_correct && !@training_submission.graded?
      @training_submission.current_step = mcq_pos + 1
      if @training_submission.done?
        @training_submission.update_grade
      end
    end

    grade_str = grade > 0 ? " + #{grade}" : ""
    if @course.mcq_auto_grader.prefer_value == 'two-one-zero'
      correct_str =  "Correct! #{grade_str}"
    else
      correct_str =  "Correct!"
    end


    resp = {
        is_correct: is_correct,
        result: is_correct ? correct_str : "Incorrect!",
        explanation: mcqas.reduce('') {|acc, n| acc << (n.explanation.length > 0 ? (n.explanation + "<br>") : "")}
    }

    if @training_submission.save
      respond_to do |format|
        format.html { render json: resp }
      end
    end

  end

  def submit_code
    require_dependency 'auto_grader'

    code = params[:code]
    coding_question = CodingQuestion.find(params[:qid])
    sma = StdCodingAnswer.new()
    sma.student = current_user
    sma.std_course = curr_user_course
    sma.qn = coding_question
    sma.code = code

    #evaluate
    code_to_write = get_code_to_write(@current_question.data_hash["included"],code)
    eval_summary = PythonEvaluator.eval_python(PythonEvaluator.get_asm_file_path(@training), code_to_write, @current_question.data_hash)
    public_tests = if eval_summary[:publicTests].length == 0 then true else eval_summary[:publicTests].inject{|sum,a| sum and a} end
    private_tests = if eval_summary[:privateTests].length == 0 then true else eval_summary[:privateTests].inject{|sum,a| sum and a} end

    #if fail private test cases, show hints
    if public_tests and eval_summary[:privateTests].length > 0 and !private_tests
      index = eval_summary[:privateTests].find_index(false)
      eval_summary[:hint] = coding_question.data_hash["privateTests"][index]["hint"]
    end

    sma.is_correct = false
    puts "judge:", eval_summary[:errors].length, public_tests, private_tests
    if eval_summary[:errors].length == 0 and public_tests and private_tests
      sma.is_correct = true
    end

    sbm_ans = @training_submission.sbm_answers.build
    sbm_ans.answer = sma

    pos = @training.get_qn_pos(coding_question)
    puts "correct!",pos,@training_submission.current_step

    if sma.is_correct && !@training_submission.graded?
      puts "correct!",pos,@training_submission.current_step
      @training_submission.current_step = pos + 1
      AutoGrader.coding_question_grader(@training_submission, coding_question,sbm_ans)
      # only update grade after finishing the assignments
      if  @training_submission.done?
        @training_submission.update_grade
      end
    end

    if @training_submission.save
      respond_to do |format|
        format.html {render json: eval_summary }
      end
    end
  end

  private
  def authorize
    if curr_user_course.is_staff?
      return true
    end

    if @training.open_at > Time.now
      redirect_to course_assessment_training_access_denied_path(@course, @training)
    end
  end
end
