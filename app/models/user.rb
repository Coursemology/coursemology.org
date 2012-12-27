class User < ActiveRecord::Base
  before_create :set_default_role
  before_create :set_default_profile_pic

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

  def is_lecturer?(course)
    uc = UserCourse.find_by_user_id_and_course_id(self.id, course.id)
    return uc.is_lecturer?
  end

  def is_student?(course)
    uc = UserCourse.find_by_user_id_and_course_id(self.id, course.id)
    return uc.is_student?
  end

  private
  def set_default_role
    if !self.role
      self.role = Role.find_by_name('normal')
    end
  end

  def set_default_profile_pic
    if !self.profile_photo_url
      self.profile_photo_url =
        'https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash4/c178.0.604.604/s160x160/252231_1002029915278_1941483569_n.jpg'
    end
  end
end
