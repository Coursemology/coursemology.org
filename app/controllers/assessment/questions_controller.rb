class Assessment::QuestionsController < ApplicationController
  load_and_authorize_resource :course
  load_resource :assessment, through: :course
  before_filter :build_resource
  before_filter :extract_tags, only: [:update]
  before_filter :load_general_course_data, only: [:show, :new, :edit]


  def new
    @question.max_grade = @assessment.is_mission? ? 10 : 2
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @question }
    end
  end

  def create
    @question.creator = current_user
    qa = @assessment.question_assessments.new
    qa.question = @question.question
    qa.position = @assessment.questions.count
    @question.save && qa.save
  end

  def update

  end

  def destroy
    @question.destroy
    respond_to do |format|
      format.html { redirect_to url_for([@course, @assessment.as_assessment]),
                                notice: "Question has been successfully deleted." }
    end
  end

  protected

  def extract_tags
    tags = (params[params[:controller].gsub('/', '_').singularize] || {}).delete(:tags) || ""
    tt = @course.tags.find_or_create_all_with_like_by_name(course_id = @course.id, tags.split(","))
    @question.tags = tt
  end

  def build_resource
    resource = params[:controller].classify.constantize
    if params[:id]
      @question = resource.send(:find, params[:id])
    elsif params[:action] == 'index'
      @questions = resource.accessible_by(current_ability)
    else
      @question = resource.new
      extract_tags
      (params[resource.to_s.underscore.gsub('/', '_')] || {}).each do |key, value|
        @question.send("#{key}=", value)
      end
    end
  end
end