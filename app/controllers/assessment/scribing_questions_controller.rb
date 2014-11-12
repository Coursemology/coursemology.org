class Assessment::ScribingQuestionsController < Assessment::QuestionsController

  def create
    assign_params
    extract_tags
    @question.creator = current_user
    qa = @assessment.question_assessments.new
    qa.question = @question.question
    qa.position = @assessment.questions.count

    file_upload = FileUpload.create({creator: current_user,
                                     owner: @question,
                                     file: params[:assessment_scribing_question][:document]
                                     })
    
    respond_to do |format|
      if @question.save && qa.save && file_upload.save
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
      if @question.update_attributes(params[:assessment_scribing_question])
        format.html { redirect_to url_for([@course, @assessment.as_assessment]),
                                  notice: 'Question has been updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end


  protected

  def build_resource
    if params[:action] == 'create'
      @question = Assessment::ScribingQuestion.new
    elsif params[:action] == 'update'
      @question = Assessment::ScribingQuestion.find(params[:id])
    else
      super
    end
  end


  private

  def assign_params
    form_params = params['assessment_scribing_question']
    @question.title = form_params[:title]
    @question.description = form_params[:description]
    @question.max_grade = form_params[:max_grade]
  end

end
