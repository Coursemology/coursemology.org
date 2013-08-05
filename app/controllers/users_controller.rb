class UsersController < ApplicationController
  load_and_authorize_resource :user
  before_filter :signed_in_user, only: [:edit,:update]

  def edit
    @setting = true
  end

  respond_to :html, :json
  def update
    #TODO: update user role could cause database inconsistency
    #TODO: send notification email for change of role
    #TODO: ugly way of insuring no hacking of updating role
    if params[:id].nil?
      authorize! :manage, current_user
      if params[:user][:system_role_id] && params[:user][:system_role_id] != current_user.system_role_id.to_s
        change_role_not_allowed
        return
      end
      puts "email address", params[:user][:email], current_user.email
      email_updated = params[:user][:email] != current_user.email

      respond_to do |format|
        if current_user.update_attributes(params[:user])
          notice = email_updated ? 'A confirmation email has been sent to yur new email address.' : 'Updated successfully.'
          format.html { redirect_to root_path, notice: notice }
        else
          format.html { render action: "edit" }
        end
      end
    elsif params[:user].to_s.size > 0
      authorize! :manage, @user
      @user.update_attributes(params[:user])
      UserMailer.delay.update_user_role(@user)
      respond_with @user
    else
      authorize! :manage, @user
      @user.name = params[:name]
      @user.email = params[:email]
      respond_to do |format|
        if @user.save
          format.html { redirect_to params[:redirect_back_url], notice: 'Updated successfully.' }
        else
          format.html { redirect_to params[:redirect_back_url], alert:"Invalid email: #{params[:email]}" }
        end
      end
    end
  end

  private
  def change_role_not_allowed
    redirect_to access_denied_path, alert: "You are not allowed to change your role."
  end

  end
