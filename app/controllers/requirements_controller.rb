class RequirementsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :requirement

  def create
    type = params[:type]
    if type == "Achievement"
      @ach = Achievement.find(params[:ach_id])
      @requirement.req = @ach
      @requirement.save
      resp = render_to_string(
        partial: "requirements/ach_req_row",
        locals: { ach_req: @requirement }
      )
      respond_to do |format|
        format.json { render text: resp }
      end
    elsif type == "AsmReq"
      @asm_req = AsmReq.create({
        asm_type: params[:asm_type],
        asm_id: params[:asm_id],
        min_grade: params[:min_grade]
      })
      @requirement.req = @asm_req
      @requirement.save
      resp = render_to_string(
        partial: "requirements/asm_req_row",
        locals: { asm_req: @requirement }
      )
      respond_to do |format|
        format.json { render text: resp }
      end
    end
  end

  def destroy
    @requirement.destroy
    respond_to do |format|
      format.json { render json: { status: "OK" } }
    end
  end
end
