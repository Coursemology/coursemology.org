class ForumForum < ActiveRecord::Base
  belongs_to :course
  has_many :topics, class_name: 'ForumTopic', foreign_key: :forum_id
  has_many :posts, through: :topics
  has_many :subscriptions, class_name: 'ForumForumSubscription', foreign_key: :forum_id


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

  def has_unanswered_question?
    topics.unanswered.count > 0
  end

  def subscriptions_for_user(user_course)
    subscriptions.where(:user_id => user_course)
  end

  def subscribed?(user_course)
    not subscriptions.where(user_id: user_course).empty?
  end

  def title
    name
  end

  def views_count
    ForumTopicView.where(topic_id: topics).count
  end

  def votes_count
    votes = ActsAsVotable::Vote.where(votable_type: ForumPost.to_s, votable_id: posts )
    votes.where(vote_flag: true).count - votes.where(vote_flag: false).count
  end
end
