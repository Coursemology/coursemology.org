class UsersController < ApplicationController
  load_and_authorize_resource :user
  before_filter :signed_in_user, only: [:edit,:update]

  def edit
    @setting = true
  end

  def show
    @setting = current_user == @user
    @admin = current_user.is_admin?
    if @admin
      @request_count = RoleRequest.count
    end
  end

  respond_to :html, :json
  def update
    #TODO: update user role could cause database inconsistency
    #TODO: send notification email for change of role
    #TODO: ugly way of insuring no hacking of updating role
    #user update info
    if params[:id].nil?
      authorize! :manage, current_user
      respond_to do |format|
        if current_user.update_attributes(params[:user])
          flash[:success] = 'Updated successfully.'
          format.html { redirect_to edit_user_path(current_user) }
        else
          format.html { redirect_to edit_user_path(current_user) }
        end
      end
    #admin update user role
    elsif params[:user].to_s.size > 0 and !params[:user][:system_role_id].nil?
      authorize! :update_role, @user
      @user.update_user_role(params[:user][:system_role_id])
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

  def destroy
    authorize! :destroy, @user
    @user.is_pending_deletion = true
    @user.save
    UserMailer.delay.user_deleted(@user.name, @user.email)
    Delayed::Job.enqueue(BackgroundJob.new(0, :delete_user, User.name, @user.id))
    respond_to do |format|
      flash[:notice] = "'#{@user.name}' is pending for deletion."
      redirect_url = params[:origin] || courses_url
      format.html { redirect_to redirect_url }
      format.json { head :no_content }
    end
  end

  private
  def change_role_not_allowed
    redirect_to access_denied_path, alert: "You are not allowed to change your role."
  end

end
