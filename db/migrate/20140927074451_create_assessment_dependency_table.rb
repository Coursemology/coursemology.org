class CreateAssessmentDependencyTable < ActiveRecord::Migration
  def up
    execute "CREATE TABLE assessment_dependency AS
              SELECT id, dependent_id
              FROM assessments
              WHERE dependent_id IS NOT NULL and dependent_id <> 0"
  end

  def down
    sql = "SELECT * FROM assessment_dependency"
    result = ActiveRecord::Base.connection.execute(sql)
    result.each do |id, dependent_id|
      a = Assessment.with_deleted.find id
      a.dependent_id = dependent_id if a
    end
    drop_table :assessment_dependency
  end
end
