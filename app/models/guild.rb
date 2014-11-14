class Guild < ActiveRecord::Base
  attr_accessible :description, :name, :course_id

  belongs_to :course
  has_many :guild_users, class_name: 'GuildUser', dependent: :destroy

end
