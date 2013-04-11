class AddIndexToExpTransaction < ActiveRecord::Migration
  def change
    add_index :exp_transactions, :user_course_id
    add_index :exp_transactions, :giver_id
  end
end
