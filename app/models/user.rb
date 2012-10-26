class User < ActiveRecord::Base
  before_create :set_default_role

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :display_name, :name, :profile_photo_url, :system_role_id

  has_many :user_courses
  has_many :courses, through: :user_courses

  belongs_to :role, class_name: "Role", foreign_key: "system_role_id"

  private
  def set_default_role
    if !self.role
      self.role = Role.find_by_name('normal')
    end
  end
end
