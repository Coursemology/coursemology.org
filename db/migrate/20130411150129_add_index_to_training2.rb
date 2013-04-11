class AddIndexToTraining2 < ActiveRecord::Migration
  def change
    add_index :trainings, :creator_id
  end
end
