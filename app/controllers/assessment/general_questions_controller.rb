class Assessment::GeneralQuestionsController < Assessment::QuestionsController
  before_filter {|c| c.build_resource Assessment::GeneralQuestion}

  def create
    saved = super
    respond_to do |format|
      if saved
        format.html { redirect_to url_for([@course, @assessment.as_assessment]),
                      notice: 'Question has been added.' }
        format.json { render json: @question, status: :created, location: @question }
      else
        format.html { render action: 'new' }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @question.update_attributes(params[:assessment_general_question])
        format.html { redirect_to url_for([@course, @assessment.as_assessment]),
                                  notice: 'Question has been updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

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
