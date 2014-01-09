class MassEnrollmentEmailsController < ApplicationController
  load_and_authorize_resource :course
  load_and_authorize_resource :mass_enrollment_email, through: :course
  before_filter :load_general_course_data, only: [:index]

  def index
    invited_stds = MassEnrollmentEmail.where(course_id: @course)
    @registered_stds = invited_stds.where(signed_up: true)
    @unregistered_stds = invited_stds.where(signed_up: false)
  end

  def send_enroll_emails
    unless params[:students]
      return
    end

    failed_emails = []
    success_count = 0
    existing_records = 0
    params[:students].each do |key, std|
      existing_record = MassEnrollmentEmail.where(course_id:@course, email: std[:email]).first
      if existing_record
        existing_records += 1
        next
      end

      existing_user = User.find_by_email(std[:email])
      if existing_user
        @course.enrol_user(existing_user, Role.student.first)
        next
      end

      enroll_inv = @course.mass_enrollment_emails.build
      enroll_inv.name = std[:name]
      enroll_inv.email = std[:email]
      enroll_inv.generate_confirm_token
      unless enroll_inv.save
        failed_emails << {
            email: std[:email],
            reason: enroll_inv.errors.full_messages.join(', ')
        }
        next
      end
      success_count += 1
    end

    Delayed::Job.enqueue(MailingJob.new(@course.id, MassEnrollmentEmail.to_s, current_user.id, new_user_registration_url), run_at: 5.minutes.from_now)

    respond_to do |format|
      if existing_records > 0
        flash[:notice] = "#{existing_records} duplicated record(s) .<br>"
      end
      if success_count > 0
        flash[:notice] ||= ""
        flash[:notice] << "#{success_count} invitation(s) created."
      end
      if failed_emails.count > 0
        flash[:error] = "#{failed_emails.count} failed due to invalid email address."
      end
      format.json {render json: {failed_emails: failed_emails} }
    end
  end

  def destroy
    @mass_enrollment_email.destroy
    respond_to do |format|
      format.html { redirect_to course_mass_enrollment_emails_path(@course),
                                notice: "#{@mass_enrollment_email.name} has been removed." }
    end

  end

  def resend_emails
    if params[:students]
      invs = MassEnrollmentEmail.where(id: params[:students])
    else
      invs = MassEnrollmentEmail.where(course_id: @course, signed_up: false)
    end

    invs.each do |enrol|
      enrol.pending_email = true
      enrol.save
    end

    Delayed::Job.enqueue(MailingJob.new(@course.id, MassEnrollmentEmail.to_s, current_user.id, new_user_registration_url), run_at: 5.minutes.from_now)

    respond_to do |format|
      flash[:notice] = "#{invs.count} email(s) are queued!"
      format.json {render json: {Status: "All sent"}}
      format.html {redirect_to course_mass_enrollment_emails_path(@course) }
    end
  end

  def delete_mass
    if params[:students]
      invs = MassEnrollmentEmail.where(id: params[:students])
    else
      invs = MassEnrollmentEmail.where(course_id: @course, signed_up: false)
    end

    count = invs.count
    invs.destroy_all
    respond_to do |format|
      flash[:notice] = "#{count} record(s) are deleted!"
      format.json {render json: {Status: "deleted"}}
      format.html {redirect_to course_mass_enrollment_emails_path(@course) }
    end

  end
end
