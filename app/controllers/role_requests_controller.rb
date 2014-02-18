class RoleRequestsController < ApplicationController
  load_and_authorize_resource :role_request

  def index
    # only admin should be able to access this page
    authorize! :can, :manage, :role_request
    @admin = true
    @request_count = RoleRequest.count
    @lecturer_requests = []
    @lecturer_role = Role.find_by_name('lecturer')
    @role_requests.each do |role_request|
      if role_request.role == @lecturer_role
        @lecturer_requests << role_request
      end
    end
  end

  def create
    request = RoleRequest.find_by_user_id_and_role_id(
        current_user.id,
        Role.lecturer.first.id
    )
    unless request
      @role_request.user = current_user
      @role_request.role = Role.lecturer.first
      @role_request.save
    end
    respond_to do |format|
      flash[:notice] = "Your request has been submitted."
      format.html {redirect_to my_courses_path}
    end
  end

  def new
    request = RoleRequest.find_by_user_id_and_role_id(
        current_user.id,
        Role.lecturer.first.id
    )
    @admin_role = Role.find_by_name('superuser')

    if request
      redirect_to role_request_path(request)
    end
  end

  def edit

  end

  def update
    respond_to do |format|
      if @role_request.update_attributes(params[:role_request])
        flash[:notice] = "Your request has been updated."
        redirect_to my_courses_path
      end
    end
  end

  def show

  end

  def destroy
    authorize! :can, :manage, :role_request
    if params[:approved]
      puts 'Request approved!'
      # create new UserCourse record
      user = @role_request.user
      user.system_role = Role.find_by_name('lecturer')
      user.save
      UserMailer.delay.new_lecturer(user)
    end

    @role_request.destroy

    respond_to do |format|
      format.json { render json: { status: 'OK' } }
      format.html {redirect_to role_requests_path}
    end
  end
end
