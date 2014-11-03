class RemoveDependentIdFromAssessment < ActiveRecord::Migration
  def up
    remove_column :assessments, :dependent_id
  end

  def down
    remove_column :assessments, :dependent_id, :integer
  end
end
