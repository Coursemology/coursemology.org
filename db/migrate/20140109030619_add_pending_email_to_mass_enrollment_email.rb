class AddPendingEmailToMassEnrollmentEmail < ActiveRecord::Migration
  def change
    add_column :mass_enrollment_emails, :pending_email, :boolean, default: true

    #existing ones should be marked as false
    MassEnrollmentEmail.all.each do |enrol|
      enrol.pending_email = false
      enrol.save
    end
  end
end
