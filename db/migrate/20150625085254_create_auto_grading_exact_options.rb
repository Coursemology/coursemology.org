class CreateAutoGradingExactOptions < ActiveRecord::Migration
  def change
    create_table :assessment_auto_grading_exact_options do |t|
      t.integer :general_question_id
      t.boolean :correct
      t.text :answer
      t.text :explanation
    end
  end
end
