class EnrollRequestsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :enroll_request, through: :course

  before_filter :load_general_course_data, only: [:index, :new]

  def index
    # only staff should be able to access this page
    # here staff can approve student to enroll to a class
    @staff_requests = []
    @student_requests = []

    std_role = Role.find_by_name("student")
    @enroll_requests.each do |er|
      if er.role == std_role
        @student_requests << er
      else
        @staff_requests << er
      end
    end
  end

  def new
    unless current_user
      redirect_to new_user_session_path
      return
    end
    unless @course.is_open?
      redirect_to course_path(@course)
      return
    end

    @er = EnrollRequest.find_by_user_id_and_course_id(current_user.id, @course.id)
    if !curr_user_course.id && !@er
      if params[:role]
        @role = Role.find_by_name(params[:role])
      else
        @role = Role.find_by_name('student')
      end
      if @role == Role.shared.first
        authorize! :ask_for_share, Course
      end
      @enroll_request.course = @course
      @enroll_request.user = current_user
      @enroll_request.role = @role
      @enroll_request.save
      @enroll_request.notify_lecturer(course_enroll_requests_url(@course))
      @er = @enroll_request
    end
  end

  def approve_request(enroll_request)
    authorize! :approve, EnrollRequest
    @course.enrol_user(enroll_request.user, enroll_request.role)
  end

  def approve_all
    authorize! :approve, EnrollRequest
    req_type = params[:req_type]
    std_role = Role.find_by_name("student")
    @enroll_requests = @course.enroll_requests
    @enroll_requests.each do |enroll_request|
      if req_type == 'student' && enroll_request.role == std_role
        approve_request(enroll_request)
        enroll_request.destroy
      end
      if req_type == 'staff' && enroll_request.role != std_role
        approve_request(enroll_request)
        enroll_request.destroy
      end
    end
    respond_to do |format|
      format.html {
        redirect_to course_enroll_requests_path(@course),
                    notice: "All requests have been approved!"
      }
    end
  end

  def approve_selected
    enroll_requests = EnrollRequest.where(id: params[:ids])
    puts params[:ids]
    puts enroll_requests.to_json
    enroll_requests.each do |enroll_request|
      puts enroll_request.to_json
      approve_request(enroll_request)
      enroll_request.destroy
    end

    respond_to do |format|
      format.html {
        redirect_to course_enroll_requests_path(@course),
                    notice: "The request(s) have been approved!"
      }
    end
  end

  def delete_all
    req_type = params[:req_type]
    std_role = Role.find_by_name("student")
    @enroll_requests = @course.enroll_requests
    @enroll_requests.each do |enroll_request|
      if req_type == 'student' && enroll_request.role == std_role
        enroll_request.destroy
      end
      if req_type == 'staff' && enroll_request.role != std_role
        enroll_request.destroy
      end
    end
    respond_to do |format|
      format.html {
        redirect_to course_enroll_requests_path(@course),
                    notice: "All requests have been deleted!"
      }
    end
  end

  def delete_selected
    enroll_requests = EnrollRequest.where(id: params[:ids])
    enroll_requests.each do |enroll_request|
      puts enroll_request.to_json
      enroll_request.destroy
    end

    respond_to do |format|
      format.html {
        redirect_to course_enroll_requests_path(@course),
                    notice: "The request(s) have been deleted!"
      }
    end
  end

  def destroy
    if params[:approved]
      puts 'Request approved!'
      # create new UserCourse record
      approve_request(@enroll_request)
    end

    @enroll_request.destroy

    respond_to do |format|
      format.json { render json: { status: 'OK' } }
    end
  end
end
