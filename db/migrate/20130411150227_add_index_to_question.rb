class AddIndexToQuestion < ActiveRecord::Migration
  def change
    add_index :questions, :creator_id
  end
end
