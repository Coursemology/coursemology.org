class CreatePendingComments < ActiveRecord::Migration
  def change
    create_table :pending_comments do |t|
      t.integer   :answer_id
      t.string    :answer_type
      t.boolean   :pending

      t.timestamps
    end

    add_index :pending_comments, :answer_id
  end
end
