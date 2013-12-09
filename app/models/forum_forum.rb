class ForumForum < ActiveRecord::Base
  belongs_to :course
  has_many :topics, class_name: 'ForumTopic', foreign_key: :forum_id
  has_many :posts, through: :topics
  has_many :subscriptions, class_name: 'ForumForumSubscriptions', foreign_key: :forum_id

  is_sluggable :name, history: false

  attr_accessible :name, :description

  def last_post
    posts.last
  end

  def unread_topics(user_course)
    topics.merge(ForumTopic.unread(user_course))
  end

  def unanswered_questions
    topics.merge(ForumTopic.unanswered)
  end

  def subscriptions_for_user(user_course)
    subscriptions.where(:user_id => user_course)
  end
end
