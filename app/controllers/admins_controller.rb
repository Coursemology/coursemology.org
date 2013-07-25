class AdminsController < ApplicationController
  before_filter :signed_in_user

  before_filter :authorize_admin

  def authorize_admin
    authorize!(:manage, :user)
  end

  def initialize
    @admin = true
    super
  end
  def show
    #logger.info "admin show"
  end

  def search
    unless params[:search].nil?
      @users = User.search params[:search]
    end
  end
end
