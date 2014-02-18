class AdminsController < ApplicationController
  before_filter :authorize_admin

  def access_control
    @summary = {query: params[:search], show: "all"}
    @summary[:admins] = User.admins.count
    @summary[:instructors] = User.lecturers.count
    @summary[:normals] = User.normals.count
    role = (params[:role].nil? || params[:role].empty?) ? nil : params[:role]
    search_param = (params[:search].nil? || params[:search].empty?) ? nil : params[:search]

    unless role.nil?
      puts role
      @summary[:role] = role
      @summary[:show] = Role.find_by_id(role).title
    end

    if role && search_param.nil?
      @users = User.where(system_role_id: params[:role]).page(params[:page]).per(50)
    elsif search_param.nil?
      @users = User.order("lower(name) asc").page(params[:page]).per(50)
    else
      search(role)
    end
  end

  def initialize
    @admin = true
    @request_count = RoleRequest.count
    super
  end
  def show
    #logger.info "admin show"
  end

  def search(role = nil)
    unless params[:search].nil?
      @users = User.search(params[:search].strip, role).order(:name).page(params[:page]).per(50)
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
