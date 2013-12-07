class ForumForum < ActiveRecord::Base
  belongs_to :course
  has_many :topics, class_name: 'ForumTopic', foreign_key: :forum_id
  has_many :posts, through: :topics

  is_sluggable :name, history: false

  attr_accessible :name, :description

  def last_post
    posts.last
  end
end
