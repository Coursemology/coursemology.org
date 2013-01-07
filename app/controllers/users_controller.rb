class UsersController < ApplicationController

  def edit
    if !current_user
      redirect_to new_user_session_path
    end
  end

  def update
    authorize! :update, current_user
    respond_to do |format|
      if current_user.update_attributes(params[:user])
        format.html { redirect_to root_path, notice: 'Course was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end
end
