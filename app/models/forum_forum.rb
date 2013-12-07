class ForumForum < ActiveRecord::Base
  set_table_name 'forum_forums'

  has_many :topics, class_name: 'ForumTopic', foreign_key: :forum_id
  has_many :posts, through: :topics

  def last_post
    posts.last
  end
end
