class AddGradeToAssignmentAndQuestion < ActiveRecord::Migration
  def change
    add_column :assignments, :max_grade, :integer
    add_column :mcqs, :max_grade, :integer
    add_column :questions, :max_grade, :integer
  end
end
