class Assessment::CodingQuestionsController < Assessment::QuestionsController
  before_filter :set_avaialbe_test_types, only: [:new, :edit]

  def new
    @question.auto_graded = !@assessment.is_mission?
    @question.language = ProgrammingLanguage.first
    super
  end

  def create
    @question.auto_graded = true if @assessment.is_training?

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

  def update
    super
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

  private

  def set_avaialbe_test_types
    @test_types = {public: 'Public', private: 'Private'}
    if @assessment.is_mission?
      @test_types[:eval] = 'Evaluation'
    end
  end

end
