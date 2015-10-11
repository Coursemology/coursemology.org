class AddUniqueIndexToSubmissions < ActiveRecord::Migration
  def change
    add_index :assessment_submissions, [:assessment_id, :std_course_id], unique: true
  end
end
