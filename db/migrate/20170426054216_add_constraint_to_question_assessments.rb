class AddConstraintToQuestionAssessments < ActiveRecord::Migration
  def change
    ids = Assessment.pluck(:id)
    QuestionAssessment.where("assessment_id NOT IN (#{ids.join(",")})").update_all(deleted_at: Time.new(2016, 1))

    change_column :question_assessments, :assessment_id, :integer, null: false
    change_column :question_assessments, :question_id, :integer, null: false
  end
end
