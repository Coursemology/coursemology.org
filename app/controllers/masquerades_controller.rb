class MasqueradesController < ApplicationController
  load_and_authorize_resource :user, only: [:new]
  before_filter :authorize_masquerade

  def authorize_masquerade
    puts 'Check if user is able to masquerade before proceed..'
    masquerading? || authorize!(:masquerade, :user)
  end

  def new
    if !masquerading?
      session[:admin_id] = current_user.id
    end
    user = User.find(params[:user_id])
    sign_in user
    redirect_to root_path, notice: "Now masquerading as #{user.name}"
  end

  def destroy
    user = User.find(session[:admin_id])
    sign_in user
    session[:admin_id] = nil
    redirect_to admins_path, notice: "Stopped masquerading"
  end
end
