class AsmQnsController < ApplicationController
  load_and_authorize_resource :course

  before_filter :load_asm, only: [:reorder]

  def load_asm
    if params[:training_id]
      @asm = @course.trainings.find(params[:assessment_training_id])
    else
      @asm = @course.missions.find(params[:assessment_mission_id])
    end
    authorize! :edit, @asm
  end

  def reorder
    params['asm-qn'].each_with_index do |id, index|
      asm_qn = @asm.questions.find(id.to_i)
      asm_qn.pos = index
      asm_qn.save
    end

    render nothing: true
  end

end
