class UserTitle < ActiveRecord::Base
  attr_accessible :is_using, :title_id, :user_id

  belongs_to :user
  belongs_to :title
end
