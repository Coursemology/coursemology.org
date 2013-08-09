class CreateCommentSubscriptions < ActiveRecord::Migration
  def change
    create_table :comment_subscriptions do |t|
      t.integer :topic_id
      t.string :topic_type
      t.integer :course_id
      t.integer :user_course_id

      t.timestamps
    end
  end
end
