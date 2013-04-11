class AddIndexToSbmAnswer < ActiveRecord::Migration
  def change
    add_index :sbm_answers, :sbm_id
    add_index :sbm_answers, :answer_id
  end
end
