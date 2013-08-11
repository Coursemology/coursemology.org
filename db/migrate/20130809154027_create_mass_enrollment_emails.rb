class CreateMassEnrollmentEmails < ActiveRecord::Migration
  def change
    create_table :mass_enrollment_emails do |t|
      t.integer   :course_id
      t.string    :name
      t.string    :email
      t.boolean   :signed_up, default: false
      t.integer   :delayed_job_id

      t.timestamps
    end
  end
end
