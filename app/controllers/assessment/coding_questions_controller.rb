class Assessment::CodingQuestionsController < Assessment::QuestionsController
  before_filter {|c| c.build_resource Assessment::CodingQuestion}

  def new
    @question.max_grade = @mission ? 10 : 1
    # puts @question.to_json
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @question }
    end
  end

  def create
    @question.creator = current_user
    @question.assessment = @assessment.assessment
    @question.pos = @question.assessment.questions.last ?
                      @question.assessment.questions.last.pos.to_i + 1 : 0

    # update max grade of the asm it belongs to
    respond_to do |format|
      if @question.save
        if @training
          format.html { redirect_to course_assessment_training_url(@course, @training),
                                    notice: 'New question added.' }
        elsif @mission
          format.html { redirect_to course_assessment_mission_path(@course, @mission),
                                    notice: 'New question added.' }
        end

        format.json { render json: @question, status: :created, location: @question }
      else
        format.html { render action: 'new' }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    @question.update_attributes(params[:assessment_coding_question])

    respond_to do |format|
      if @question.save
        if @training
          format.html { redirect_to course_assessment_training_url(@course, @training),
                                    notice: 'Question has been updated.' }
          format.json { head :no_content }
        elsif @mission
          format.html { redirect_to course_assessment_mission_path(@course, @mission),
                                    notice: 'Question has been updated.' }
          format.json { head :no_content }
        end
      else
        format.html { render action: 'edit' }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @question.destroy
    respond_to do |format|
      format.html { redirect_to url_for([@course, @assessment]) }
    end
  end
end
