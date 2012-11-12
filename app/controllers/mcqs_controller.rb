class McqsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :assignment, through: :course
  load_and_authorize_resource :mcq, through: :assignment

  def new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @mcq }
    end
  end

  def create
    @mcq.creator = current_user
    respond_to do |format|
      if @mcq.save
        format.html { redirect_to course_assignment_mcq_url(@course, @assignment, @mcq),
                      notice: 'Assignment was successfully created.' }
        format.json { render json: @mcq, status: :created, location: @mcq }
      else
        format.html { render action: "new" }
        format.json { render json: @mcq.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @mcq.update_attributes(params[:mcq])
        format.html { redirect_to course_assignment_mcq_url(@course, @assignment, @mcq),
                      notice: 'Assignment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @mcq.errors, status: :unprocessable_entity }
      end
    end
  end



  def show
  end
end
