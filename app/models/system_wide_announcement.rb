class SystemWideAnnouncement < ActiveRecord::Base
  # System wide announcements are announcements sent through email to all the
  # users in the entire system.
  #
  # TODO: Send to users in a specific course
  # TODO: Send to users in a specific user group

  attr_accessible :subject, :body
  validates :body, presence: true
end
