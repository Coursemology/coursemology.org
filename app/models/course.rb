class Course < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :creator_id, :description, :logo_url, :title
  before_create :populate_preference

  belongs_to :creator, class_name: "User"

  has_many :missions,       dependent: :destroy
  has_many :announcements,  dependent: :destroy
  has_many :user_courses,   dependent: :destroy
  has_many :trainings,      dependent: :destroy

  has_many :mcqs,             through: :trainings
  has_many :coding_questions, through: :trainings

  has_many :users, through: :user_courses

  has_many :std_answers,        through: :user_courses
  has_many :std_coding_answers, through: :user_courses

  has_many :submissions,          through: :user_courses
  has_many :training_submissions, through: :user_courses

  has_many :activities, dependent: :destroy

  has_many :levels,       dependent: :destroy
  has_many :achievements, dependent: :destroy

  has_many :tags,       dependent: :destroy
  has_many :tag_groups, dependent: :destroy

  has_many :course_themes, dependent: :destroy  # currently only has one though

  has_many :tutorial_groups,        dependent: :destroy
  has_many :file_uploads,           as: :owner
  has_many :course_preferences,     dependent: :destroy
  has_many :comment_subscriptions,  dependent: :destroy
  has_many :mass_enrollment_emails, dependent: :destroy
  has_many :enroll_requests,        dependent: :destroy

  def asms
    missions + trainings
  end

  def commented_topics
    self.comment_subscriptions.map { |cs| cs.topic }.uniq
  end

  def lect_courses
    user_courses.joins(:role).where('roles.name' => 'lecturer')
  end

  def student_courses
    self.user_courses.student
  end

  def get_pending_gradings(curr_user_course)
    if curr_user_course.is_lecturer?
      @pending_gradings = submissions.where(status:"submitted").order(:submit_at)
    else
      @pending_gradings = submissions.where(status:"submitted",std_course_id:curr_user_course.get_my_stds).order(:submit_at)
    end
  end

  def get_all_answers
    std_answers + std_coding_answers + mcqs + coding_questions
  end

  def get_pending_comments
    self.commented_topics.select(&:pending?)
  end

  def mission_columns
    self.course_preferences.mission_columns
  end

  def training_columns
    self.course_preferences.training_columns
  end

  def mcq_auto_grader
    self.course_preferences.select { |pref| pref.preferable_item.item == "Mcq" && pref.preferable_item.item_type == "AutoGrader"}.first
  end

  def student_sidebar_items
    self.course_preferences.student_sidebar_items
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
    self.course_preferences.select { |pref| pref.preferable_item.item == "Mission" &&
        pref.preferable_item.item_type == "Time" }.first
  end

  def training_time_format
    self.course_preferences.select { |pref| pref.preferable_item.item == "Training" &&
        pref.preferable_item.item_type == "Time" }.first
  end

  def training_table_paging
    self.course_preferences.select { |pref| pref.preferable_item.item == "Training" &&
        pref.preferable_item.item_type == "Table" &&
        pref.preferable_item.name == 'paging' }.first
  end

  def mission_table_paging
    self.course_preferences.select { |pref| pref.preferable_item.item == "Mission" &&
        pref.preferable_item.item_type == "Table" &&
        pref.preferable_item.name == 'paging' }.first
  end

  def email_notifications
    course_preferences.email_notifications
  end

  def email_notify_enabled?(item)
    enabled_notifications.include? item
  end

  def enabled_notifications
    email_notifications.select {|pref| pref.display }.map { |pref| pref.preferable_item.name }
  end

  def course_home_sections
    course_preferences.course_home_sections
  end

  def enabled_course_home_sections
    course_home_sections.select { |pref| pref.display }
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

  def enrol_user(user, role)
    if UserCourse.where(course_id: self, user_id: user).first
      return
    end
    self.user_courses.create(user_id: user.id, role_id: role.id)
  end
end
