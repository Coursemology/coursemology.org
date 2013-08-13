class CoursePreference < ActiveRecord::Base
  attr_accessible :course_id, :preferable_item_id, :prefer_value, :display

  belongs_to  :course
  belongs_to  :preferable_item

  scope :training_reattempt,    where(preferable_item_id: PreferableItem.training_reattempt.first)
  scope :mission_columns,       where(preferable_item_id: PreferableItem.mission_columns)
  scope :training_columns,      where(preferable_item_id: PreferableItem.training_columns)
  scope :student_sidebar_items, where(preferable_item_id: PreferableItem.student_sidebar_items)
  scope :email_notifications,   where(preferable_item_id: PreferableItem.email_notifications)
  scope :course_home_sections,  where(preferable_item_id: PreferableItem.course_home_sections)
  scope :course_home_events_no, where(preferable_item_id: PreferableItem.home_sections_events_no)


end
