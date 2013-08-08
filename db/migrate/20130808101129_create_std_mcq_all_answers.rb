class CreateStdMcqAllAnswers < ActiveRecord::Migration
  def change
    create_table :std_mcq_all_answers do |t|
      t.text :selected_choices
      t.integer :student_id
      t.integer :mcq_id
      t.integer :std_course_id
      t.text :choices

      t.timestamps
    end
  end
end
