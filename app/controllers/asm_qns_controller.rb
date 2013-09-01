class AsmQnsController < ApplicationController
  load_and_authorize_resource :course

  before_filter :load_asm, only: [:reorder]

  def load_asm
    if params[:training_id]
      @asm = @course.trainings.find(params[:training_id])
    else
      @asm = @course.missions.find(params[:mission_id])
    end
    authorize! :edit, @asm
  end

  def reorder
    # binding.pry
    params['asm-qn'].each_with_index do |id, index|
      # binding.pry
      asm_qn = @asm.asm_qns.find(id.to_i)
      asm_qn.pos = index
      asm_qn.save
    end
    # binding.pry

    render nothing: true
  end

end
