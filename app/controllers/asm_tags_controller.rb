class AsmTagsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :asm_tag, except: [:render]

  def render_form_row
    tag = Tag.find(params[:tag_id])
    resp = render_to_string(
      partial: "form_row",
      locals: { tag: tag }
    )
    respond_to do |format|
      format.json { render text: resp }
    end
  end

  def destroy
    @requirement.destroy
    respond_to do |format|
      format.json { render json: { status: "OK" } }
    end
  end
end
