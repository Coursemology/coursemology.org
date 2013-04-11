class AddIndexToEnrollRequest < ActiveRecord::Migration
  def change
    add_index :enroll_requests, :course_id
    add_index :enroll_requests, :role_id
  end
end
