class Assessment::CodingQuestionsController < Assessment::QuestionsController
  before_filter {|c| c.build_resource Assessment::CodingQuestion}

  def new
    @question.max_grade = @assessment.is_mission? ? 10 : 2
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @question }
    end
  end

  def create
    saved = super
    # update max grade of the asm it belongs to
    respond_to do |format|
      if saved
        flash[:notice] = 'New question added.'
        format.html { redirect_to url_for([@course, @assessment.as_assessment]) }
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
        flash[:notice] = 'Question has been updated.'
        format.html { redirect_to url_for([@course, @assessment.as_assessment]) }
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
