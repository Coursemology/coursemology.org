class AddQuestionIdToStudentAnswer < ActiveRecord::Migration
  def change
    add_column :student_answers, :answerable_id, :integer
    add_column :student_answers, :answerable_type, :string
  end
end
