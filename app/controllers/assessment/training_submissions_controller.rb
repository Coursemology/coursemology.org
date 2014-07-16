class Assessment::TrainingSubmissionsController < Assessment::SubmissionsController

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


  def show
    @training = @assessment.specific
    @grading = @submission.get_final_grading

    # @qadata = {}

    # @training.questions.each_with_index do |qn, index|
    #   break if @submission.current_step <= index && !@training.can_skip?
    #   @qadata[qn.id.to_s+qn.class.to_s] = {q: qn}
    # end
    #
    # @std_answers_for_questions =  Hash.new{ |h, k| h[k] = [] }
    # @submission.get_all_answers.each do |sma|
    #   @std_answers_for_questions[sma.qn_id.to_s + sma.qn.class.to_s] << sma
    # end
    #
    # @qadata.each do |qid, qa|
    #   if @std_answers_for_questions.has_key?(qid)
    #     @qadata[qid][:a] = @std_answers_for_questions[qid].sort_by(&:created_at)
    #   end
    # end
    #
    # if @grading
    #   @grading.answer_gradings.each do |ag|
    #     if (sta = ag.student_answer) and sta.qn
    #       @qadata[sta.qn_id.to_s + sta.qn.class.to_s][:g] = ag
    #     end
    #   end
    # end
  end

  def edit
    #1. half way, redirect to next undone question, or finalised one if requested, or requested one if stuff or skippable
    #2. finished, list all submissions

    #implementation, build step control UI separately
    # @next_undone
    @training = @assessment.specific
    questions = @assessment.questions
    finalised = @assessment.questions.finalised(@submission)
    current =  (questions - finalised).first
    next_undone = (questions.index(current) || questions.length) + 1
    request_step = (params[:step] || next_undone).to_i
    step = (curr_user_course.is_staff? || @training.skippable?) ? request_step : [next_undone , request_step].min
    current = step > questions.length ? current : questions[step - 1]

    current = current.specific if current
    if current && current.class == Assessment::CodingQuestion
      @prefilled_code = current.data_hash["prefill"]
      if current.dependent_on
        std_answer = current.dependent_on.answers.where("correct is 1 AND std_course_id = ?", curr_user_course.id).last
        code = std_answer ? std_answer.answer : ""
        @prefilled_code = "#Answer from your previous question \n" + code + (@prefilled_code.empty? ? "" : ("\n\n#prefilled code \n" + @prefilled_code))
      end
    end

    @summary = {questions: questions, finalised: finalised, step: step, current: current, next_undone: next_undone}
  end

  def submit
    question = @assessment.questions.find_by_id(params[:qid]).specific

    response = {}
    case
      when question.class == Assessment::McqQuestion
        response = submit_mcq(question)
      when question.class == Assessment::CodingQuestion
        response = submit_code(question)
      else
        #nothing yet
    end


    respond_to do |format|
      format.json {render json: response}
    end
  end

  def submit_mcq(question)
    selected_options = question.options.find_all_by_id(params[:aid])
    eval_array = selected_options.map(&:correct)
    incomplete = false
    correct = eval_array.reduce {|x, y| x && y}

    if correct && question.select_all?
      correct = selected_options.length == question.options.where(correct: true).count
      incomplete = !correct
    end

    ans = @submission.answers.create(
        {std_course_id: curr_user_course.id,
         question_id: question.question.id,
         correct: correct,
         finalised: correct
        })
    ans.answer_options.create(selected_options.map {|so| {option_id: so.id}})

    grade  = 0
    pref_grader = @course.mcq_auto_grader.prefer_value

    if correct && !@submission.graded?
      grade = AutoGrader.mcq_grader(@submission, ans, question, pref_grader)
      if @submission.done?
        @submission.update_grade
      end
    end

    if pref_grader == 'two-one-zero'
      grade_str = grade > 0 ? " + #{grade}" : ""
      correct_str =  "Correct! #{grade_str}"
    else
      correct_str =  "Correct!"
    end

    if question.select_all?
      if incomplete
        explanation = "Not all correct answers are selected."
      else
        c_count = eval_array.select{|x| x}.length
        explanation = "#{c_count} correct, #{eval_array.length - c_count} wrong"
      end
    else
      explanation = selected_options.first.explanation
    end

    {is_correct: correct,
     result: correct ? correct_str : "Incorrect!",
     explanation: explanation
    }
  end


  def submit_code(question)
    require_dependency 'auto_grader'

    code = params[:code]
    sma = @submission.answers.create({std_course_id: curr_user_course.id,
                                      question_id: question.question.id,
                                      answer: code,
                                      correct: false})

    #evaluate
    code_to_write = PythonEvaluator.combine_code(question.data_hash["included"], code)
    eval_summary = PythonEvaluator.eval_python(PythonEvaluator.get_asm_file_path(@assessment), code_to_write, question)
    public_tests = eval_summary[:public].length == 0 ? true : eval_summary[:public].inject{|sum,a| sum and a}
    private_tests = eval_summary[:private].length == 0 ? true : eval_summary[:private].inject{|sum,a| sum and a}

    #if fail private test cases, show hints
    if public_tests and eval_summary[:private].length > 0 and !private_tests
      index = eval_summary[:private].find_index(false)
      eval_summary[:hint] = question.data_hash["private"][index]["hint"]
    end

    if eval_summary[:errors].length == 0 and public_tests and private_tests
      sma.correct = true
      sma.finalised = true
      sma.save
    end

    if sma.correct && !@submission.graded?
      AutoGrader.coding_question_grader(@submission, question, sma)
      # only update grade after finishing the assignments
      if @submission.done?
        @submission.update_grade
      end
    end
    eval_summary
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
