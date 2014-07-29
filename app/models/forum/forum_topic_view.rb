class ForumTopicView < ActiveRecord::Base
  belongs_to :topic, class_name: 'ForumTopic', foreign_key: 'topic_id'
  belongs_to :user, class_name: 'UserCourse', foreign_key: 'user_id'
end
