class AddCustomForumTopicViews < ActiveRecord::Migration
  def change
    create_table :forum_topic_views do |t|
      t.integer :topic_id
      t.integer :user_id
      t.timestamps
    end

    add_index :forum_topic_views, [:topic_id]
  end
end
