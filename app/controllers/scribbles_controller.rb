class ScribblesController < ApplicationController

  def create
    if scribble_params['id'] != ""
      @scribble = Scribble.find(scribble_params['id'])
    else
      @scribble = Scribble.where({
        std_course_id: scribble_params[:std_course_id],
        scribing_answer_id: scribble_params[:scribing_answer_id]
      }).first
    end
    if @scribble
      @scribble.update_attributes(scribble_params)
    else
      @scribble = Scribble.new(scribble_params)
    end
    @scribble.save

    respond_to do |format|
      format.json { render :json => @post }
    end
  end

  private

  def scribble_params
    params[:scribble].slice :content, :std_course_id, :scribing_answer_id, :id
  end

end
