class UserCourse < ActiveRecord::Base
  attr_accessible :course_id, :exp, :role_id, :user_id

  belongs_to :role
  belongs_to :user
  belongs_to :course

  has_one :user_exp
  has_many :user_achievements
  has_many :user_titles
  has_many :user_rewards

  def is_student?
    return self.role.name == 'student'
  end

  def is_lecturer?
    return self.role.name == 'lecturer'
  end
end
