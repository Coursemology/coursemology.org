class CreateAssessmentScribingAnswers < ActiveRecord::Migration
  def change
    create_table :assessment_scribing_answers do |t|
    	t.timestamp :deleted_at

      t.timestamps
    end
  end
end
