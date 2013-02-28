class RoleRequestsController < ApplicationController
  load_and_authorize_resource :role_request

  def index
    # only admin should be able to access this page
    @lecturer_requests = []
    @lecturer_role = Role.find_by_name('lecturer')
    @role_requests.each do |role_request|
      if role_request.role == @lecturer_role
        @lecturer_requests << role_request
      end
    end
  end

  def new
    @lecturer_role = Role.find_by_name('lecturer')
    @admin_role = Role.find_by_name('superuser')
    @request = RoleRequest.find_by_user_id_and_role_id(
      current_user.id,
      @lecturer_role.id
    )
    if current_user && !current_user.is_lecturer? && !@request
      User.admins.each { |u| UserMailer.delay.new_lecturer_request(u) }
      @request = RoleRequest.new
      @request.user = current_user
      @request.role = @lecturer_role
      @request.save
    end
  end

  def destroy
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
    end
  end
end
