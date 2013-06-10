class UsersController < ApplicationController
  def edit
    if !current_user
      redirect_to new_user_session_path
    else
      @setting = true
    end
  end

  respond_to :html, :json
  def update
    #TODO: update user role could cause database inconsistency
    #TODO: send notification email for change of role
    if :id.nil?
      authorize! :update, current_user
      respond_to do |format|
        if current_user.update_attributes(params[:user])
          format.html { redirect_to root_path, notice: 'Updated successfully.' }
        else
          format.html { render action: "edit" }
        end
      end
    else
      @user = User.find(params[:id])
      @user.update_attributes(params[:user])
      UserMailer.delay.update_user_role(@user)
      respond_with @user
    end


    #respond_to do |format|
    #  if @user.update_attributes(params[:user])
    #    format.html { redirect_to root_path, notice: 'Updated successfully.' }
    #  else
    #    format.html { render action: "edit" }
    #  end
    #end
    #redirect_to :back
  end

  def show
    @admin = true
    @users = User.search params[:search]
  end
end
