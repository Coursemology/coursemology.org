class ForumTopic < ActiveRecord::Base
  has_many :posts, class_name: 'ForumPost', foreign_key: :topic_id, dependent: :delete_all
  has_many :views, class_name: 'ForumTopicView', foreign_key: :topic_id, dependent: :delete_all
  has_many :subscriptions, class_name: 'ForumTopicSubscription', foreign_key: :topic_id
  belongs_to :author, class_name: 'UserCourse', foreign_key: :author_id
  belongs_to :forum, class_name: 'ForumForum'

  scope :questions, -> {
    where(topic_type: TOPIC_TYPE_QUESTION)
  }
  scope :unread, ->(user_course) {
    joins('LEFT OUTER JOIN seen_by_users ON
      seen_by_users.user_course_id = ' + (user_course.id ? user_course.id.to_s : '0') + ' AND
      seen_by_users.obj_id=forum_topics.id AND
      obj_type=\'ForumTopic\'').where(seen_by_users: { obj_id: nil })
  }
  scope :unanswered, -> {
    questions.joins('LEFT OUTER JOIN forum_posts ON
      forum_posts.topic_id = forum_topics.id AND
      forum_posts.answer <> 0').
    where(forum_posts: { id: nil })
  }

  is_sluggable :title, history: false

  attr_accessible :forum, :topic_type, :locked, :hidden

  # Defines all topic types
  TOPIC_TYPES = [
      ['Normal', 0],
      ['Question', 1],
      ['Sticky', 2],
      ['Announcement', 3]
  ]
  TOPIC_TYPE_NORMAL = 0
  TOPIC_TYPE_QUESTION = 1
  TOPIC_TYPE_STICKY = 2
  TOPIC_TYPE_ANNOUNCEMENT = 3

  def announcement?
    topic_type == TOPIC_TYPE_ANNOUNCEMENT
  end

  def sticky?
    topic_type == TOPIC_TYPE_STICKY
  end

  def question?
    topic_type == TOPIC_TYPE_QUESTION
  end

  def answered?
    question? && (not posts.where('answer <> 0').empty?)
  end

  def unread?(user_course)
    SeenByUser.forum_topics.where(:user_course_id => user_course, :obj_id => self.id).empty?
  end

  def can_be_replied_to?
    not(locked?)
  end

  def subject
    posts.first.title and return unless posts.empty?
    nil
  end

  def view_count
    views.count
  end
end
