class UsersController < ApplicationController
  load_and_authorize_resource :user
  before_filter :signed_in_user, only: [:edit,:update,:show]

  def edit
    @setting = true
  end

  respond_to :html, :json
  def update
    #TODO: update user role could cause database inconsistency
    #TODO: send notification email for change of role
    if params[:id].nil?
      #authorize! :update, @user
      respond_to do |format|
        if current_user.update_attributes(params[:user])
          format.html { redirect_to root_path, notice: 'Updated successfully.' }
        else
          format.html { render action: "edit" }
        end
      end
    elsif params[:user].to_s.size > 0
      @user.update_attributes(params[:user])
      UserMailer.delay.update_user_role(@user)
      respond_with @user
    else
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


    def show
      @admin = true
      unless params[:search].nil?
        @users = User.search params[:search]
      end
    end

  end
