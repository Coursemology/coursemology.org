class Assessment::QuestionsController < ApplicationController
  load_and_authorize_resource :course
  load_resource :assessment, through: :course
  before_filter :load_general_course_data, only: [:show, :new, :edit]

  def create
    @question.creator = current_user
    qa = @assessment.question_assessments.new
    qa.question = @question.question
    qa.position = @assessment.questions.count
    @question.save && qa.save
  end

  protected

  def build_resource(resource)
    if params[:id]
      @question = resource.send(:find, params[:id])
    elsif params[:action] == 'index'
      @questions = resource.accessible_by(current_ability)
    else
      @question = resource.new
      (params[resource.to_s.underscore.gsub('/', '_')] || {}).each do |key, value|
        @question.send("#{key}=", value)
      end
    end
  end
end