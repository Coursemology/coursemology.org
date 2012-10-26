class CreateEnrollRequests < ActiveRecord::Migration
  def change
    create_table :enroll_requests do |t|
      t.integer :user_id
      t.integer :course_id
      t.integer :role_id

      t.timestamps
    end
  end
end
