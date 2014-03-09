class MissionCodingQuestionsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :mission, through: :course

  before_filter :load_resource, only: [:new, :create, :edit, :update, :destroy]
  before_filter :load_general_course_data, only: [:show, :index, :new, :edit]

  def new
    @coding_question.max_grade = 10
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @coding_question }
    end
  end

  def create
    @coding_question.creator = current_user
    @asm_qn = AsmQn.new
    @asm_qn.asm = @mission
    @asm_qn.qn = @coding_question
    @asm_qn.pos = @mission.asm_qns.count + 1

    respond_to do |format|
      if @coding_question.save && @asm_qn.save
        @mission.update_grade
        format.html { redirect_to course_mission_url(@course, @mission),
                                  notice: 'Question has been added.' }
        format.json { render json: @coding_question, status: :created, location: @coding_question }
      else
        format.html { render action: "new" }
        format.json { render json: @coding_question.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @coding_question.update_attributes(params[:coding_question])
        @mission.update_grade
        format.html { redirect_to course_mission_url(@course, @mission),
                                  notice: 'Question has been updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @coding_question.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @coding_question.destroy
    @mission.update_grade
    @mission.update_qns_pos
    respond_to do |format|
      format.html { redirect_to @mission.get_path }
    end
  end

  private
  def load_resource
    if params[:id]
      @coding_question = CodingQuestion.find(params[:id])
    elsif params[:coding_question]
      @coding_question = CodingQuestion.create(params[:coding_question])
    else
      @coding_question = CodingQuestion.new
    end
  end
end