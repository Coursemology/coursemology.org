class ScribblesController < ApplicationController

  def create
    @scribble = Scribble.new(scribble_params)
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
