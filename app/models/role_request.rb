class RoleRequest < ActiveRecord::Base
  attr_accessible :role_id, :user_id, :organization, :designation, :reason

  belongs_to :user
  belongs_to :role

  after_create :send_notification

  def self.exist_lecturer_request?(current_user)
    RoleRequest.find_by_user_id_and_role_id(
        current_user.id,
        Role.lecturer.first.id
    )
  end

  def send_notification
    User.admins.each { |u| UserMailer.delay.new_lecturer_request(u, self) }
  end

end
