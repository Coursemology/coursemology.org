class SurveySubmissionsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :survey, through: :course
  load_and_authorize_resource :survey_submission, through: :survey

  before_filter :allow_only_one_submission, only: [:new, :create]
  before_filter :load_general_course_data, only: [:show, :edit, :new]

  def new
    if @survey_submission.save
      respond_to do |format|
        format.html { redirect_to edit_course_survey_survey_submission_path(@course, @survey, @survey_submission) }
      end
    end
  end

  def create
    update
  end

  def edit
    @current_qn = @survey_submission.current_qn || 1
    @step = @current_qn

    @editable = !@survey_submission.submitted? ||  @survey.allow_modify?

    if params[:_pos] && params[:_pos].to_i >= 1
      @step = params[:_pos].to_i
    else
      @step = 1
    end
  end

  def update
  end

  def show
    edit
  end

  def submit
    unless !@survey_submission.submitted? ||  @survey.allow_modify?
      respond_to do |format|
        flash[:error] ="No Modification is allowed"
        format.html { redirect_to course_survey_survey_submission_path(@course, @survey, @survey_submission)}
      end
      return
    end

    if @survey.is_contest?
      submit_single_question
    else
      answers = {}
      params[:answers].each do |vals|
        qn = @survey.questions.where(id: vals.first).first
        if qn
          answers[qn] = vals.last
        end
      end
      @survey.questions.each do |qn|
        if qn.is_essay?
          essay =  qn.survey_essay_answers.where(user_course_id:curr_user_course).first || @survey_submission.survey_essay_answers.build({user_course_id: curr_user_course.id, question_id: qn.id})
          if answers.has_key? qn
            essay.text = answers[qn]
            essay.save
          else
            essay.destroy
          end
        else
          #TODO: improve
          selected = qn.survey_mrq_answers.where(user_course_id:curr_user_course)
          selected.each do |ans|
            ans.option.decrease_count
            ans.destroy
          end
          if answers.has_key? qn
            options = SurveyQuestionType.MCQ.first == qn.type ? [answers[qn]] : answers[qn]

            options.each do |option|
              answer = @survey_submission.survey_mrq_answers.build({option_id: option, user_course_id: curr_user_course.id, question_id: qn.id})
              answer.save
              answer.option.increase_count
            end
          end
        end
      end
      is_submit = params[:commit] != 'Save'
      is_finished = false
      answered_qns = answers.keys
      @survey_submission.current_qn = answered_qns.length
      @survey_submission.save

      if is_submit
        required_qns = @survey.questions.select {|qn| qn.is_required? }
        is_finished = (required_qns - answered_qns) == []
      end

      respond_to do |format|
        if is_submit and is_finished
          @survey_submission.set_submitted
          format.html {redirect_to course_surveys_path,
                                   notice: "You have submitted survey: #{@survey.title}"}
        else
          format.html {redirect_to edit_course_survey_survey_submission_path(@course, @survey, @survey_submission),
                                   notice: "Survey status has been saved."}
        end
      end
    end
  end



  private
  def allow_only_one_submission
    sub = @survey.submission_by(curr_user_course.id)
    if sub
      @survey_submission = sub
    else
      @survey_submission.user_course = curr_user_course
    end
    @survey_submission.set_started
  end

  #TODO: potentially, user can choose to render survey in three ways
  def submit_single_page

  end

  def submit_single_question
    step =  params[:step].to_i
    redirect_url = edit_course_survey_survey_submission_path(@course, @survey, @survey_submission)
    unless params[:option]
      respond_to do |format|
        flash[:error] ="No option is selected."
        format.html {redirect_to  redirect_url + "?_pos=#{step}" }
      end
      return
    end

    question = @survey.survey_questions.where(id:params[:question]).first
    options = params[:option].keys.map {|k| k.to_i}
    if question.max_choices < options.count
      flash[:error] = "Max response allowed is #{question.max_choices}, but #{options.count} have been selected."
    else
      answers = question.survey_mrq_answers.where(user_course_id:curr_user_course)

      was_selected = answers.map{|ans| ans.option_id }
      was_selected.each_with_index do |id, index|
        unless options.include? id
          answers[index].option.decrease_count
          answers[index].destroy
        end
      end
      (options - was_selected).each do |id|
        answer = question.survey_mrq_answers.build
        answer.option_id = id
        answer.user_course = curr_user_course
        answer.survey_submission = @survey_submission
        answer.save
        answer.option.increase_count
      end

      step += 1

      if @survey_submission.done?
        @survey_submission.set_submitted
      end
    end
    respond_to do |format|
      format.html {redirect_to redirect_url + "?_pos=#{step}"}
    end
  end

  def submit_single_section

  end
end