class Course < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :creator_id, :description, :logo_url, :title
  before_create :populate_preference

  belongs_to :creator, class_name: "User"

  has_many :missions, dependent: :destroy
  has_many :announcements, dependent: :destroy
  has_many :user_courses, dependent: :destroy
  has_many :trainings, dependent: :destroy

  has_many :users, through: :user_courses

  has_many :std_answers, through: :user_courses
  has_many :std_coding_answers, through: :user_courses

  has_many :submissions, through: :user_courses
  has_many :training_submissions, through: :user_courses

  has_many :activities, dependent: :destroy

  has_many :levels, dependent: :destroy
  has_many :achievements, dependent: :destroy

  has_many :enroll_requests, dependent: :destroy

  has_many :tags, dependent: :destroy
  has_many :tag_groups, dependent: :destroy

  has_many :course_themes, dependent: :destroy  # currently only has one though

  has_many :tutorial_groups, dependent: :destroy
  has_many :file_uploads, as: :owner
  has_many :course_preferences, dependent: :destroy

  def asms
    missions + trainings
  end

  def lect_courses
    user_courses.joins(:role).where('roles.name' => 'lecturer')
  end

  def student_courses
    std = Role.find_by_name("student")
    self.user_courses.where(role_id: std.id)
  end

  def get_pending_gradings(curr_user_course)
    if curr_user_course.is_lecturer?
      @pending_gradings = submissions.where(status:"submitted").order(:submit_at)
    else
      @pending_gradings = submissions.where(status:"submitted",std_course_id:curr_user_course.get_my_stds).order(:submit_at)
    end
  end

  def get_all_answers
    std_answers + std_coding_answers
  end

  def get_pending_comments
    self.get_all_answers.select { |ans| ans.pending? }
  end

  def get_all_comments
    self.get_all_answers.select { |ans| ans.last_commented_at }
  end

  def mission_columns
    self.course_preferences.select { |pref| pref.preferable_item.item == "Mission" && pref.preferable_item.item_type == "Column" }
  end

  def training_columns
    self.course_preferences.select { |pref| pref.preferable_item.item == "Training" && pref.preferable_item.item_type == "Column" }
  end

  def student_sidebar_items
    self.course_preferences.select { |pref| pref.preferable_item.item == "Sidebar" && pref.preferable_item.item_type == "Student" }
  end

  def student_sidebar_display
    student_sidebar_items.select {|pref| pref.display }
  end

  def mission_columns_display
    mission_columns.select {|pref| pref.display }
  end

  def training_columns_display
    training_columns.select {|pref| pref.display }
  end

  def mission_time_format
    self.course_preferences.select { |pref| pref.preferable_item.item == "Mission" && pref.preferable_item.item_type == "Time" }.first
  end

  def training_time_format
    self.course_preferences.select { |pref| pref.preferable_item.item == "Training" && pref.preferable_item.item_type == "Time" }.first
  end

  def email_notifications
    self.course_preferences.select {|pref| pref.preferable_item.item == "Email" && pref.preferable_item.item_type == "Course" }
  end

  def email_notify_enabled?(item)
    enabled_notifications.include? item
  end

  def enabled_notifications
    email_notifications.select {|pref| pref.display }.map { |pref| pref.preferable_item.name }
  end

  def populate_preference
    course_preferences.each do |pref|
      item = PreferableItem.where(id: pref.preferable_item_id).first
      unless item
        CoursePreference.destroy(pref)
      end
    end

    PreferableItem.all.each do |item|
      cp = CoursePreference.where(course_id:self.id, preferable_item_id: item.id).first
      unless cp
        pref = self.course_preferences.build
        pref.preferable_item = item
        pref.prefer_value = item.default_value
        pref.display = item.default_display
        pref.save
      end
    end
  end
end
