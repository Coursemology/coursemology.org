class Assessment::McqAnswersController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :mcq_answer

  def create
    @mcq_answer = McqAnswer.create(params[:mcq_answer])
    @mcq_answer.creator = current_user
    if @mcq_answer.save
      resp = render_to_string(
        partial: "mcq_answers/form_row",
        locals: { answer: @mcq_answer}
      )
      respond_to do |format|
        format.json { render text: resp }
      end
    end
  end

  def update
    @mcq_answer.update_attributes(params[:mcq_answers])
    resp = render_to_string(
      partial: "mcq_answers/form_row",
      locals: { answer: @mcq_answer}
    )
    respond_to do |format|
      format.json { render text: resp }
    end
  end

  def destroy
    @mcq_answer.destroy
    respond_to do |format|
      format.json { render json: { status: "OK" } }
    end
  end
end
