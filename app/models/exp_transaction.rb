class ExpTransaction < ActiveRecord::Base
  acts_as_paranoid
  # after_save :update_user_data
  after_destroy :update_user_data

  attr_accessible :exp, :giver_id, :is_valid, :reason, :user_course_id, :created_at
  attr_accessible :rewardable_id, :rewardable_type

  belongs_to :giver, class_name: "User"
  belongs_to :user_course
  belongs_to :rewardable, polymorphic: true

  def update_user_data
    self.user_course.update_exp_and_level
  end
end
