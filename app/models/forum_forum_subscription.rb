class ForumForumSubscription < ActiveRecord::Base
  belongs_to :forum, class_name: 'ForumForum'
  belongs_to :user, class_name: 'UserCourse'
end
