class ChangeColumnNullInAssessments < ActiveRecord::Migration
  def change
    change_column_null :assessments, :as_assessment_id, false
    change_column_null :assessments, :as_assessment_type, false
  end
end
