class AdminsController < ApplicationController
  before_filter :authorize_admin

  def access_control
    if params[:search].nil? || params[:search].empty?
      @users = User.order("lower(name) asc").page(params[:page]).per(50)
    end
    search
  end

  def initialize
    @admin = true
    @request_count = RoleRequest.count
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
    @summary = {all:false, query: params[:search]}

    if params[:search].nil? or params[:search].empty?
      @courses = Course
      @summary[:total_course] = Course.count
      @summary[:active_course] = UserCourse.active_last_week.group(:course_id).length
      @summary[:active_students] = UserCourse.student.active_last_week.count
      @summary[:total_students] = UserCourse.student.count
      @summary[:all] = true
    else
      @courses = Course.search(params[:search].strip).order(:title)
      ids = @courses.map {|c| c.id }
      @summary[:total_course] = @courses.length
      ucs = UserCourse.where(course_id: ids)
      @summary[:active_course] = ucs.active_last_week.group(:course_id).length
      @summary[:active_students] = ucs.student.active_last_week.count
      @summary[:total_students] = ucs.student.count
    end

    if sort_column
      @courses = @courses.order("#{sort_column} #{sort_direction}")
    else
      @courses = @courses.order(:title)
    end
    @courses = @courses.page(params[:page]).per(30)

    if params[:origin]
      redirect_to params[:origin]
    end
  end

  private
  def authorize_admin
    authorize!(:manage, :user)
  end
end
