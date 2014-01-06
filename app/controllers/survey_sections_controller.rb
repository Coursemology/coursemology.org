class SurveySectionsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :survey, through: :course
  load_and_authorize_resource :survey_section, through: :survey

  def new
  end

  def show

  end

  def edit
  end

  def index
  end

  def create
    @survey_section.pos = @survey.survey_sections.count + 1

    respond_to do |format|
      if @survey_section.save
        flash[:notice] = 'New section added.'
      end
      format.html { redirect_to course_survey_url(@course, @survey) }
    end
  end

  def update
  end

  def destroy
  end

  def reorder
    params['asm-qn'].each_with_index do |id, index|
      # binding.pry
      section = @survey.sections.find(id)
      section.pos = index
      section.save
    end
    render nothing: true
  end

end
