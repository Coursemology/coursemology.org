class AddConfirmTokenToMassEnrollmentEmails < ActiveRecord::Migration
  def change
    add_column :mass_enrollment_emails, :confirm_token, :string
  end
end
