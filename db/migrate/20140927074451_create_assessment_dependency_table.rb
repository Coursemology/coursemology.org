class CreateAssessmentDependencyTable < ActiveRecord::Migration
  def up
    execute "CREATE TABLE assessment_dependency AS
              SELECT as_assessment_id, dependent_id
              FROM assessments
              WHERE dependent_id IS NOT NULL and dependent_id <> 0"
  end

  def down
    drop_table :assessment_dependency
  end
end
