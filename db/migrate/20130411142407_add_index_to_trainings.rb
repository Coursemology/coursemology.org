class AddIndexToTrainings < ActiveRecord::Migration
  def change
    add_index :trainings, :course_id
  end
end
