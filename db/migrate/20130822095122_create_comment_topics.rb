class CreateCommentTopics < ActiveRecord::Migration
  def change
    create_table :comment_topics do |t|
      t.integer :course_id
      t.integer :topic_id
      t.string :topic_type
      t.datetime :last_commented_at
      t.boolean :pending
      t.string :permalink

      t.timestamps
    end
    add_index :comment_topics, [:topic_id, :topic_type]
    add_index :comment_topics, :pending
  end
end
