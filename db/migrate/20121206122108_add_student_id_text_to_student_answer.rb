class AddStudentIdTextToStudentAnswer < ActiveRecord::Migration
  def change
    add_column :student_answers, :student_id, :integer
    add_column :student_answers, :text, :string
  end
end
