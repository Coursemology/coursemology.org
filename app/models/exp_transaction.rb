class ExpTransaction < ActiveRecord::Base
  acts_as_paranoid

  after_create :update_user_data
  after_destroy :update_user_data
  after_update :update_user_data, :if => :exp_changed?

  attr_accessible :exp, :reason
  # attr_accessible :exp, :giver_id, :is_valid, :reason, :user_course_id, :created_at
  # attr_accessible :rewardable_id, :rewardable_type

  belongs_to :giver, class_name: "User"
  belongs_to :user_course
  belongs_to :rewardable, polymorphic: true
  

  #TODO:
  #BUG: achievement rewarding is based on grade for mission, not exp
  def update_user_data
    puts "Update user data"
    self.user_course.update_exp_and_level_async
  end

  
  #Only training exp transaction is not editable, since it's auto-graded
  def can_edit_exp?
    rewardable_type != Training.to_s
  end

  def is_manual_reward?
    rewardable_type.nil?
  end
  
  #Linking transaction to submission 
  def get_submission_path
    s = SubmissionGrading.where(exp_transaction_id: self.id).first
    s.nil? ? nil : s.sbm.get_path
  end

end
