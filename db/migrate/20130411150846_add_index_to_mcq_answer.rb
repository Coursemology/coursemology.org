class AddIndexToMcqAnswer < ActiveRecord::Migration
  def change
    add_index :mcq_answers, :mcq_id
    add_index :mcq_answers, :creator_id
  end
end
