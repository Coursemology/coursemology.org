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
      @users = User.search(params[:search].strip).order(:name).page(params[:page]).per(50)
    end
    if params[:origin]
      redirect_to params[:origin]
    end
  end

  def masquerades
    search
  end

  def courses
    unless params[:search].nil?
      @courses = Course.search(params[:search].strip).order(:title).page(params[:page]).per(50)
    else
      @courses = Course.order("created_at desc").limit(50).page(params[:page]).per(50)
    end
    if params[:origin]
      redirect_to params[:origin]
    end
  end

  private
  def authorize_admin
    authorize!(:manage, :user)
  end
end
