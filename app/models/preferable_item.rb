class PreferableItem < ActiveRecord::Base
  attr_accessible :item, :item_type, :name, :default_value, :description, :default_display


  scope :student_sidebar_items,   where(item: "Sidebar", item_type: "Student")
  scope :other_sidebar_items,     where(item: "Sidebar", item_type: "Other")
  scope :email_notifications,     where(item: "Email", item_type: "Course")
  scope :course_home_sections,    where(item: "CourseHome", item_type: "Section")
  scope :home_sections_events_no, where(item: "CourseHome", item_type: "SectionShow")

  def self.new_comment
    'new_comment'
  end

  def self.new_grading
    'new_grading'
  end

  def self.new_submission
    'new_submission'
  end

  def self.new_student
    'new_student'
  end

  def self.new_enroll_request
    'new_enroll_request'
  end

  def self.new_announcement
    'new_announcement'
  end

  def self.new_mission
    'new_mission'
  end

  def self.new_training
    'new_training'
  end

  def self.mission_due
    'mission_due'
  end
end
