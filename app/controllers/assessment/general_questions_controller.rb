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
end
