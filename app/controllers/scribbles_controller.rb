class ScribblesController < ApplicationController

  def create
    if scribble_params['id'] == ""
      @scribble = Scribble.new(scribble_params)
    else
      @scribble = Scribble.find(scribble_params['id'])
      @scribble.update_attributes(scribble_params)
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
