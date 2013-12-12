class InitCustomForum < ActiveRecord::Migration
  def change
    create_table :forum_forums do |t|
      t.integer :course_id
      t.string :name
      t.string :cached_slug
      t.text :description
    end

    add_index :forum_forums, [:cached_slug], unique: true

    create_table :forum_forum_subscriptions do |t|
      t.integer :forum_id
      t.integer :user_id
    end

    create_table :forum_topics do |t|
      t.integer :forum_id
      t.string :title
      t.string :cached_slug
      t.integer :author_id
      t.boolean :locked, :default => false
      t.boolean :hidden, :default => false
      t.integer :topic_type, :default => 0

      t.timestamps
    end

    add_index :forum_topics, [:cached_slug], unique: true
    add_index :forum_topics, [:author_id]
    add_index :forum_topics, [:forum_id]

    create_table :forum_topic_subscriptions do |t|
      t.integer :topic_id
      t.integer :user_id
    end

    create_table :forum_topic_views do |t|
      t.integer :topic_id
      t.integer :user_id
      t.timestamps
    end

    add_index :forum_topic_views, [:topic_id]

    create_table :forum_posts do |t|
      t.integer :topic_id
      t.integer :parent_id
      t.string :title
      t.integer :author_id
      t.boolean :answer
      t.text :text

      t.timestamps
    end

    add_index :forum_posts, [:author_id]
    add_index :forum_posts, [:parent_id]
    add_index :forum_posts, [:topic_id]

    create_table :forum_post_votes do |t|
      t.integer :post_id
      t.integer :vote

      t.timestamps
    end
  end
end
