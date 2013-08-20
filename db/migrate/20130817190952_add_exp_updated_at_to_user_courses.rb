class AddExpUpdatedAtToUserCourses < ActiveRecord::Migration
  def change
    add_column :user_courses, :exp_updated_at, :timestamp

    UserCourse.all.each do |uc|
      exp_ts = uc.exp_transactions.order("created_at DESC").first
      if exp_ts
        uc.exp_updated_at = exp_ts.created_at
      else
        uc.exp_updated_at = uc.updated_at
      end
      uc.save
    end
  end
end
