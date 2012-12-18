class EnrollRequestsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :enroll_request, through: :course

  def index
    # only staff should be able to access this page
    # here staff can approve student to enroll to a class
    @staff_requests = []
    @student_requests = []

    std_role = Role.find_by_name("student")

    puts @enroll_requests

    @enroll_requests.each do |er|
      if er.role == std_role
        @student_requests << er
      else
        @staff_requests << er
      end
    end

    puts 'Student Request', @student_requests
    puts 'Staff Request', @staff_requests
  end

  def new
    @uc = UserCourse.find_by_user_id_and_course_id(current_user.id, @course.id)
    @er = EnrollRequest.find_by_user_id_and_course_id(current_user.id, @course.id)

    puts 'User course', @uc
    puts 'Enroll Request', @er

    if !@uc && !@er
      if params[:role]
        role = Role.find_by_name(params[:role])
      else
        role = Role.find_by_name('student')
      end
      @enroll_request.course = @course
      @enroll_request.user = current_user
      @enroll_request.role = role
      @enroll_request.save
      @er = @enroll_request
    end
    puts 'er ', @er
    # else, render the view
  end

  def destroy
    puts params

    if params[:approved]
      puts 'Request approved!'

      # create new UserCourse record
      uc = UserCourse.new
      uc.course = @enroll_request.course
      uc.user = @enroll_request.user
      uc.role = @enroll_request.role

      std = Role.find_by_name('student')
      if uc.role == std
        # create UserExp record
        ux = UserExp.new
        ux.exp = 0
        ux.user_course = uc
        ux.save
      end

      uc.save
    end

    @enroll_request.destroy

    respond_to do |format|
      format.json { render json: { status: 'OK' } }
    end
  end
end
