class Assessment::SubmissionsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :assessment, through: :course, class: "Assessment"
  load_and_authorize_resource :submission, through: :assessment, class: "Assessment::Submission", id_param: "id", except: :new
  before_filter :load_general_course_data, only: [:show, :new, :create, :edit]

  before_filter :build_resource, only: :new

  def new
    sbm = @assessment.submissions.where(std_course_id: curr_user_course).last
    if curr_user_course.is_student? && sbm.nil?
      Activity.attempted_asm(curr_user_course, @assessment)
    end

    if sbm
      @submission = sbm
    else
      if curr_user_course.id
        @submission.std_course = curr_user_course
      else
        redirect_to access_denied_path, alert: 'You are not enrolled to this course.'
        return
      end
    end

    if @assessment.is_a?(Assessment::Training)
      @reattempt = @course.training_reattempt
      #continue unfinished training, or go to finished training of can't reattempt
      if sbm && (!sbm.graded? ||  !@reattempt || !@reattempt.display)
        redirect_to edit_course_assessment_submission_path(@course, @assessment, sbm)
        return
      end
      sbm_count = @assessment.submissions.where(std_course_id: curr_user_course).count
      if sbm_count > 0
        @submission.multiplier = @reattempt.prefer_value.to_f / 100
      end
      @submission.save
      @submission.gradings.create({grade: 0, std_course_id: curr_user_course.id})
    end

    if @submission.save
      respond_to do |format|
        format.html { redirect_to edit_course_assessment_submission_path(@course, @assessment, @submission)}
      end
    end
  end

  def set_hints(evaluate_result, question)
    # if fail private test cases, show hints
    public_tests = evaluate_result[:public].length == 0 ? true : evaluate_result[:public].inject { |sum, a| sum && a }
    private_tests = evaluate_result[:private].length == 0 ? true : evaluate_result[:private].inject { |sum, a| sum && a }
    if public_tests && evaluate_result[:private].length > 0 && !private_tests
      index = evaluate_result[:private].find_index(false)
      evaluate_result[:hint] = question.data_hash["private"][index]["hint"]
    end
  end

  private

  def build_resource
    if params[:id]
      @submission = @assessment.submissions.send(:find, params[:id])
    elsif params[:action] == 'index'
      @submissions = @assessment.submissions.accessible_by(current_ability)
    else
      @submission = @assessment.submissions.new
    end
  end
end
