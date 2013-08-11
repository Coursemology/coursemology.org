class AdminsController < ApplicationController
  before_filter :authorize_admin

  def access_control
    search
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
      @users = User.search(params[:search].strip).sort_by { |user| user.name.downcase }
      @users = Kaminari.paginate_array(@users).page(params[:page]).per(50)
    end
    if params[:origin]
      redirect_to params[:origin]
    end
  end

  def masquerades
       search
  end

  private
  def authorize_admin
    authorize!(:manage, :user)
  end
end
