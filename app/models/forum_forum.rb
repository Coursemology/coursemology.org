class ForumForum < ActiveRecord::Base
  has_many :topics, class_name: 'ForumTopic', foreign_key: :forum_id
  has_many :posts, through: :topics

  def last_post
    posts.last
  end
end
