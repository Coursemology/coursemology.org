class CoursePreference < ActiveRecord::Base
  attr_accessible :course_id, :preferable_item_id, :prefer_value, :display

  belongs_to  :course
  belongs_to  :preferable_item

  scope :training_reattempt,    where(preferable_item_id: PreferableItem.training_reattempt.first)
  scope :assessment_columns, -> { joins(:preferable_item).
      where("preferable_items.item_type = ?", 'Column')} do
    def mission
      where("preferable_items.item = ?", 'Mission')
    end

    def training
      where("preferable_items.item = ?", 'Training')
    end
  end

  scope :enabled, -> { where(display: true) }

  scope :student_sidebar_items, where(preferable_item_id: PreferableItem.student_sidebar_items)
  scope :other_sidebar_items,   where(preferable_item_id: PreferableItem.other_sidebar_items)
  scope :email_notifications,   where(preferable_item_id: PreferableItem.email_notifications)
  scope :course_home_sections,  where(preferable_item_id: PreferableItem.course_home_sections)
  scope :course_home_events_no, where(preferable_item_id: PreferableItem.home_sections_events_no)
  scope :course_paging_prefs,   where(preferable_item_id: PreferableItem.paging_prefs)

  default_scope includes(:preferable_item)


  before_update :schedule_auto_sbm_job, :if => :display_changed?
  after_update :update_related_pref, :if => :prefer_value_changed?

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

  def update_related_pref
    #expire cache
    course.student_courses.each do |uc|
      ActionController::Base.new.expire_fragment("sidebar/#{course.id}/uc/#{uc.id}")
    end
    if preferable_item.name == 'announcements' and
        preferable_item.item == 'Sidebar' and
        preferable_item.item_type == 'Student'
      ann = course.home_sections.where("preferable_items.name = 'announcements'").first
      ann.prefer_value = prefer_value
      ann.save
    elsif preferable_item.name == 'missions' and
        preferable_item.item == 'Sidebar' and
        preferable_item.item_type == 'Student'
      col = course.mission_columns.where("preferable_items.name = 'title'").first
      col.prefer_value = prefer_value.singularize
      col.save
    elsif preferable_item.name == 'trainings' and
        preferable_item.item == 'Sidebar' and
        preferable_item.item_type == 'Student'
      col = course.training_columns.where("preferable_items.name = 'title'").first
      col.prefer_value = prefer_value.singularize
      col.save
    end
  end
end
