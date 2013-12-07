class ForumPost < ActiveRecord::Base
  belongs_to :topic, class_name: 'ForumTopic', foreign_key: 'topic_id'
  belongs_to :author, class_name: 'UserCourse', foreign_key: 'author_id'
  belongs_to :parent, class_name: 'ForumPost', foreign_key: 'parent_id'
  has_many :children, class_name: 'ForumPost', foreign_key: 'parent_id'

  attr_accessible :title, :text, :parent_id
  acts_as_votable

  def unread?(user_course)
    SeenByUser.forum_posts.where(user_course_id: user_course, obj_id: self).empty?
  end

  def destroy
    ForumPost.transaction do
      # Set all child references to the parent of the item we are deleting.
      children.each do |post|
        post.parent = @post.parent
        post.save
      end

      reload
      super
    end
  end
end
