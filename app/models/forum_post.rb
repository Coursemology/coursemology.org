class ForumPost < ActiveRecord::Base
  belongs_to :author, class_name: 'UserCourse', foreign_key: 'author_id'
end
