class ForumTopic < ActiveRecord::Base
  has_many :posts, class_name: 'ForumPost', foreign_key: :topic_id
end
