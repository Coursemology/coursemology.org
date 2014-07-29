class ForumTopicSubscription < ActiveRecord::Base
  belongs_to :topic, class_name: 'ForumTopic'
  belongs_to :user, class_name: 'UserCourse'
end
