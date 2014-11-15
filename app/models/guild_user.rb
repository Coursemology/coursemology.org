class GuildUser < ActiveRecord::Base

  attr_accessible :role_id, :user_course_id, :guild_id

  belongs_to :guild
  belongs_to :user_course

end
