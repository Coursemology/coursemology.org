class ForumPost < ActiveRecord::Base
  include ActivityObject
  include Rails.application.routes.url_helpers

  belongs_to :topic, class_name: 'ForumTopic', foreign_key: 'topic_id'
  belongs_to :author, class_name: 'UserCourse', foreign_key: 'author_id'
  belongs_to :parent, class_name: 'ForumPost', foreign_key: 'parent_id'
  has_many :children, class_name: 'ForumPost', foreign_key: 'parent_id'

  attr_accessible :title, :text, :parent_id
  acts_as_votable

  after_create :send_notification

  def send_notification
    Delayed::Job.enqueue(MailingJob.new(author.course.id, ForumPost.to_s, self.id, ""), run_at: Time.now)
  end

  def unread?(user_course)
    SeenByUser.forum_posts.where(user_course_id: user_course, obj_id: self).empty?
  end

  def vote_count
    upvotes.count - downvotes.count
  end

  def destroy
    ForumPost.transaction do
      # Set all child references to the parent of the item we are deleting.
      children.each do |post|
        post.parent = parent
        post.save
      end

      # If the topic this belongs to is now an empty shell, delete it.
      old_topic = topic
      reload
      super

      if old_topic.posts.empty?
        old_topic.destroy
      end
    end
  end

  # Implements ActivityObject
  def get_title
    topic.title
  end

  def get_path
    edit_course_forum_topic_post_path(topic.forum.course, topic.forum, topic, self)
  end
end
