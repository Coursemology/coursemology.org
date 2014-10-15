class Assessment::TrainingSubmissionsController < Assessment::SubmissionsController

  skip_load_and_authorize_resource :training_submission
  skip_load_and_authorize_resource :training, only: :listall

  before_filter :authorize, only: [:new, :edit]
  before_filter :load_general_course_data, only: [:show, :edit]


  def show
    @training = @assessment.specific
    @grading = @submission.get_final_grading
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
    step = step > questions.length ? next_undone : step
    current = step > questions.length ? current : questions[step - 1]
    finished = finalised.include? current

    current = current.specific if current
    if current && current.class == Assessment::CodingQuestion
      prefilled_code = current.template
      if current.dependent_on
        std_answer = current.dependent_on.answers.where("correct = 1 AND std_course_id = ?", curr_user_course.id).last
        code = std_answer ? std_answer.content : ""
        prefilled_code = "#Answer from your previous question \n" + code + (prefilled_code.empty? ? "" : ("\n\n#prefilled code \n" + prefilled_code))
      end
    end

    @summary = { questions: questions, finalised: finalised, step: step,
                 current: current, next_undone: next_undone, prefilled: prefilled_code,
                 finished: finished, last_attempt: code_of_last_attempt(current) }
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

    ans = Assessment::McqAnswer.create({std_course_id: curr_user_course.id,
                                        question_id: question.question.id,
                                        submission_id: @submission.id,
                                        correct: correct,
                                        finalised: correct
                                       })
    ans.answer_options.create(selected_options.map {|so| {option_id: so.id}})

    grade  = 0
    pref_grader = @course.mcq_auto_grader.prefer_value

    if correct && !@submission.graded?
      grade = AutoGrader.mcq_grader(@submission, ans.answer, question, pref_grader)
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
      elsif correct
        explanation = question.options.pluck(:explanation).
            delete_if(&:blank?).join("<br>")
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
    sma = Assessment::CodingAnswer.create({ std_course_id: curr_user_course.id,
                                            question_id: question.question.id,
                                            submission_id: @submission.id,
                                            content: code}).answer

    #evaluate
    code_to_write = PythonEvaluator.combine_code([question.pre_include, code, question.append_code])
    eval_summary = PythonEvaluator.eval_python(PythonEvaluator.get_asm_file_path(@assessment), code_to_write, question)

    public_tests, private_tests = set_hints(eval_summary, question)

    if eval_summary[:errors].length == 0 && public_tests && private_tests
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

  def code_of_last_attempt(question)
    return unless question

    ans = question.answers.where(std_course_id: curr_user_course.id).last
    ans.content if ans
  end

  private
  def authorize
    if curr_user_course.is_staff?
      return true
    end

    unless @assessment.can_start?(curr_user_course)
      redirect_to access_denied_course_assessment_path(@course, @assessment)
    end
  end
end
