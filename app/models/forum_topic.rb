class ForumTopic < ActiveRecord::Base
  set_table_name 'forum_topics'

  has_many :posts, class_name: 'ForumPost', foreign_key: :topic_id
end
