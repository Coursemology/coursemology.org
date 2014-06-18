class Assessment::CodingQuestionsController < ApplicationController
  load_and_authorize_resource :course
  # load_and_authorize_resource :question, class: "Assessment::CodingQuestion"
  before_filter :load_resources

  # before_filter :load_general_course_data, only: [:new, :edit]

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
          format.html { redirect_to course_training_url(@course, @training),
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
          format.html { redirect_to course_training_url(@course, @training),
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
                    Assessment::CodingQuestion.new
                  when 'create'
                    q = Assessment::CodingQuestion.new
                    q.attributes = params[:assessment_coding_question]
                    q
                  else
                    Assessment::CodingQuestion.find_by_id!(params[:id] || params[:assessment_coding_question_id])
                end
    # @question = Assessment::CodingQuestion.new
    # puts ::Assessment::CodingQuestion
    # puts Assessment::Training
    # puts CodingQuestion
    puts "I AM HERE"
  end
end
