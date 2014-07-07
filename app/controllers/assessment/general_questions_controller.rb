class Assessment::GeneralQuestionsController < ApplicationController
  load_and_authorize_resource :course
  before_filter :load_resources
#   load_and_authorize_resource :mission, class: "Assessment::Mission", through: :course
#   load_and_authorize_resource :question, class: "Assessment::GeneralQuestion",  through: :mission
#
#   # before_filter :load_general_course_data, only: [:show, :index, :new, :edit]
#
#   def new
#     @question.max_grade = 10
#     respond_to do |format|
#       format.html # new.html.erb
#       format.json { render json: @question }
#     end
#   end
#
  def create
    @question.creator = current_user
    qa = @mission.assessment.question_assessments.new
    qa.question = @question.question
    @question.position = @mission.questions.last ?
                      @mission.questions.last.pos.to_i + 1 : 0

    respond_to do |format|
      if @question.save  && qa.save
        format.html { redirect_to course_assessment_mission_url(@course, @mission),
                      notice: 'Question has been added.' }
        format.json { render json: @question, status: :created, location: @question }
      else
        format.html { render action: 'new' }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end
#
#   def update
#     respond_to do |format|
#       if @question.update_attributes(params[:assessment_text_question]) && @question.save
#         format.html { redirect_to course_assessment_mission_path(@course, @mission),
#                       notice: 'Question has been updated.' }
#         format.json { head :no_content }
#       else
#         format.html { render action: 'edit' }
#         format.json { render json: @question.errors, status: :unprocessable_entity }
#       end
#     end
#   end
#
#   def destroy
#     @question.destroy
#     respond_to do |format|
#       format.html { redirect_to url_for([@course, @assessment]) }
#     end
#   end
#
private
  def load_resources
    if params[:assessment_mission_id]
      @mission = Assessment::Mission.find(params[:assessment_mission_id])
    elsif params[:assessment_training_id]
      @training = Assessment::Training.find(params[:assessment_training_id])
    end
    @assessment = @mission || @training
    authorize! params[:action].to_sym, @assessment

    @question = case params[:action]
                  when 'new'
                    Assessment::GeneralQuestion.new
                  when 'create'
                    q = Assessment::GeneralQuestion.new
                    q.attributes = params[:assessment_general_question]
                    q
                  else
                    Assessment::GeneralQuestion.find_by_id!(params[:id]  || params[:assessment_text_question_id])
                end
  end
end
