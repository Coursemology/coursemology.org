class AddStudentAnswerTypeToAnswerGrading < ActiveRecord::Migration
  def change
    add_column :answer_gradings, :student_answer_type, :string
  end
end
