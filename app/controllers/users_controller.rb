class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:edit,:update,:show]

  def edit
      @setting = true
  end

  respond_to :html, :json
  def update
    #TODO: update user role could cause database inconsistency
    #TODO: send notification email for change of role
    if params[:id].nil?
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
  end

  def show
    @admin = true
    unless params[:search].nil?
      @users = User.search params[:search]
    end
  end

end
