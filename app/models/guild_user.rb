class GuildUser < ActiveRecord::Base

  attr_accessible :role

  belongs_to :guild
  has_one :user_course
end
