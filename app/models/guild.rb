class Guild < ActiveRecord::Base

  attr_accessible :description, :name, :course_id

  belongs_to :course

  has_many :guild_users, class_name: 'GuildUser', dependent: :destroy
  #need to set up associations with users? (Probably for leaders?)
  #need to set up table?

  #to add validation

end
