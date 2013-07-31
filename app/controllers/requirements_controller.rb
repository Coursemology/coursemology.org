class RequirementsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :requirement

  def render_form_row
    type = params[:type]
    @requirement = Requirement.new
    # don't save the requirement, we just want to create one to render the row
    if type == "Achievement"
      @ach = Achievement.find(params[:ach_id])
      @requirement.req = @ach
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
      resp = render_to_string(
        partial: "requirements/asm_req_row",
        locals: { asm_req: @requirement }
      )
      respond_to do |format|
        format.json { render text: resp }
      end
    elsif type == "Level"
      @lvl_req = Level.find(params[:lvl_id])
      @requirement.req = @lvl_req
      resp = render_to_string(
        partial: "requirements/lvl_req_row",
        locals: { lvl_req: @requirement}
      )
      respond_to do |format|
        format.json { render text: resp }
      end
    end
  end

  def destroy
    @asm_tag.destroy
    respond_to do |format|
      format.json { render json: { status: "OK" } }
    end
  end
end
