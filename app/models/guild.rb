class Guild < ActiveRecord::Base

  belongs_to :course

  has_many :GuildUsers
  has_many :members, class_name: "User", through: :Guild_User do
    def leaders
      where("guild_user.role_id = ?", 1)
    end
  end

  attr_accessible :description, :name

  #to add validation

end
