class CustomForumInit < ActiveRecord::Migration
  def change
    create_table :forum_forums do |t|
      t.integer :course_id
      t.string :name
      t.string :slug
      t.text :description
    end

    create_table :forum_forum_subscriptions do |t|
      t.integer :forum_id
      t.integer :user_id
    end

    create_table :forum_topics do |t|
      t.integer :forum_id
      t.string :slug
      t.integer :author_id
      t.boolean :locked, :default => false
      t.boolean :hidden, :default => false
      t.integer :topic_type, :default => 0

      t.timestamps
    end

    create_table :forum_topic_subscriptions do |t|
      t.integer :topic_id
      t.integer :user_id
    end

    create_table :forum_posts do |t|
      t.integer :topic_id
      t.integer :parent_id
      t.integer :author_id
      t.boolean :answer
      t.text :text

      t.timestamps
    end

    create_table :forum_post_votes do |t|
      t.integer :post_id
      t.integer :vote

      t.timestamps
    end
  end
end
