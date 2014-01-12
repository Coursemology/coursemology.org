class CoursePreference < ActiveRecord::Base
  attr_accessible :course_id, :preferable_item_id, :prefer_value, :display

  belongs_to  :course
  belongs_to  :preferable_item

  scope :training_reattempt,    where(preferable_item_id: PreferableItem.training_reattempt.first)
  scope :mission_columns,       where(preferable_item_id: PreferableItem.mission_columns)
  scope :training_columns,      where(preferable_item_id: PreferableItem.training_columns)
  scope :student_sidebar_items, where(preferable_item_id: PreferableItem.student_sidebar_items)
  scope :other_sidebar_items,   where(preferable_item_id: PreferableItem.other_sidebar_items)
  scope :email_notifications,   where(preferable_item_id: PreferableItem.email_notifications)
  scope :course_home_sections,  where(preferable_item_id: PreferableItem.course_home_sections)
  scope :course_home_events_no, where(preferable_item_id: PreferableItem.home_sections_events_no)
  scope :course_paging_prefs,   where(preferable_item_id: PreferableItem.paging_prefs)

  default_scope includes(:preferable_item)


  before_update :schedule_auto_sbm_job, :if => :display_changed?

  def schedule_auto_sbm_job
    if preferable_item == PreferableItem.where(item: 'Mission', item_type: 'Submission', name: 'auto').first
      if display?
        Delayed::Job.enqueue(BackgroundJob.new(course_id, 'AutoSubmissions', 'Create'))
      else
        Delayed::Job.enqueue(BackgroundJob.new(course_id, 'AutoSubmissions', 'Cancel'))
      end
    end
  end

  def self.fetch

  end
end
