class CreateAutoGradingKeywordOptions < ActiveRecord::Migration
  def change
    create_table :assessment_auto_grading_keyword_options do |t|
      t.integer :general_question_id
      t.string :keyword
      t.integer :score
    end
  end
end
