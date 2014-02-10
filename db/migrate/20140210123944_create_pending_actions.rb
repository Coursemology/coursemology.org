class CreatePendingActions < ActiveRecord::Migration
  def change
    create_table :pending_actions do |t|
      t.integer   :course_id
      t.integer   :user_course_id
      t.integer   :item_id
      t.string    :item_type
      t.boolean   :is_ignored,  default: false
      t.boolean   :is_done,     default: false

      t.timestamps
    end

    add_index :pending_actions, :user_course_id
  end
end
