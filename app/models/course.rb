class Course < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :creator_id, :description, :logo_url, :title, :is_publish, :is_active, :is_open
  before_create :populate_preference
  after_create :create_materials_root

  belongs_to :creator, class_name: "User"

  has_many :missions,          dependent: :destroy
  has_many :announcements,     dependent: :destroy
  has_many :user_courses ,     dependent: :destroy
  has_many :trainings,         dependent: :destroy
  has_many :lesson_plan_entries, dependent: :destroy
  has_many :lesson_plan_milestones, dependent: :destroy
  has_one  :material_folder,   dependent: :destroy, :conditions => { :parent_folder_id => nil }

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
  has_many :comment_topics,         dependent: :destroy
  has_many :mass_enrollment_emails, dependent: :destroy
  has_many :enroll_requests,        dependent: :destroy
  has_many :tutor_monitorings,      dependent: :destroy
  has_many :surveys,                dependent: :destroy

  after_create :populate_forum

  def asms
    missions + trainings
  end

  # def commented_topics
  #  # self.comment_subscriptions.map { |cs| cs.topic }.select{ |cs| cs.}.uniq
  #  self.comment_subscriptions.reduce([]) { |acc, cs| cs.topic.comments.count > 0 ? acc.push(cs.topic) : acc }.uniq
  #end

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
    self.comment_topics.where(pending: true)
  end

  def count_pending_comments
    self.comment_topics.where(pending: true).count
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

  def trainings_paging_pref
    paging_pref('Trainings')
  end

  def missions_paging_pref
    paging_pref('Missions')
  end

  def announcements_paging_pref
    paging_pref('Announcements')
  end

  def missions_stats_paging_pref
    paging_pref('MissionStats')
  end

  def mission_sbm_paging_pref
    paging_pref('MissionSubmissions')
  end

  def training_stats_paging_pref
    paging_pref('TrainingStats')
  end

  def training_sbm_paging_pref
    paging_pref('TrainingSubmissions')
  end

  def comments_paging_pref
    paging_pref('Comments')
  end

  def achievements_paging_pref
    paging_pref('Achievements')
  end

  def students_paging_pref
    paging_pref('Students')
  end

  def mgmt_std_paging_pref
    paging_pref('ManageStudents')
  end

  def std_summary_paging_pref
    paging_pref('StudentSummary')
  end

  def paging_pref(page)
    self.course_preferences.course_paging_prefs.select { |pref| pref.preferable_item.item_type == page}.first
  end

  def achievements_locked_display
    self.course_preferences.select { |pref| pref.preferable_item.item == "Achievements" &&
        pref.preferable_item.item_type == "Icon" &&
        pref.preferable_item.name == 'locked' }.first
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

  def home_sections
    course_preferences.course_home_sections
  end

  def enabled_course_home_sections
    course_home_sections.select { |pref| pref.display }
  end

  def course_home_events_no_pref
    course_preferences.course_home_events_no
  end

  def course_paging_prefs
    course_preferences.course_paging_prefs
  end

  def leaderboard_no_pef
    self.course_preferences.select { |pref| pref.preferable_item.item == "Leaderboard" &&
        pref.preferable_item.item_type == "Display" &&
        pref.preferable_item.name == 'leaders' }.first
  end

  def home_announcement_pref
    home_sections.select { |pref| pref.preferable_item.name == "announcements" }.first
  end

  def home_activities_pref
    home_sections.select { |pref| pref.preferable_item.name == 'activities' }.first
  end

  def home_announcement_no_pref
    course_home_events_no_pref.select  { |pref| pref.preferable_item.name == "announcements_no" }.first
  end

  def home_activities_no_pref
    course_home_events_no_pref.select { |pref| pref.preferable_item.name == "activities_no" }.first
  end

  def auto_create_sbm_pref
    course_preferences.select { |pref| pref.preferable_item.item == 'Mission' and
        pref.preferable_item.item_type == 'Submission' and
        pref.preferable_item.name == 'auto' }.first
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

  def populate_forum
    begin
      cat = Forem::Category.find(self.id)
    rescue ActiveRecord::RecordNotFound
      cat = Forem::Category.create(:id => self.id, :name => self.title)
      Forem::Forum.create(:category_id => cat.id,
                          :name => 'General Discussion',
                          :description => 'For general discussion')
      Forem::Forum.create(:category_id => cat.id,
                          :name => 'Help',
                          :description => 'Ask your questions here')
    end
  end

  def create_materials_root
    MaterialFolder.create(:course => self, :name => "Root")
  end

  def enrol_user(user, role)
    if UserCourse.where(course_id: self, user_id: user).first
      return
    end
    self.user_courses.create(user_id: user.id, role_id: role.id)
  end

  def pending_surveys(user_course)
    if user_course.is_student?
      self.surveys.where("open_at < ? and expire_at > ? and publish = true", Time.now, Time.now).select {|s| !s.submission_by(user_course) }
    else
      []
    end
  end

  def self.online_course
    Course.where(is_publish: true)
  end

  def lesson_plan_virtual_entries(from = nil, to = nil)
    missions = self.missions.where("TRUE " +
      (if from then "AND open_at >= :from " else "" end) +
      (if to then "AND open_at <= :to" else "" end),
      :from => from, :to => to
    )

    entries = missions.map { |m| m.as_lesson_plan_entry }

    trainings = self.trainings.where("TRUE " +
      (if from then "AND open_at >= :from " else "" end) +
      (if to then "AND open_at <= :to" else "" end),
      :from => from, :to => to
    )

    entries += trainings.map { |t| t.as_lesson_plan_entry }
  end

  def workbin_virtual_entries
    mission_files =
      # Get the missions' files, and map it to the virtual entries.
      (self.missions.map { |m|
        m.files.map { |f|
          material = Material.create_virtual(m, f)
          material.file = f
          material.filename = m.title + ": " + f.original_name
          material.filesize = f.file_file_size
          material.updated_at = f.file_updated_at
          material.url = f.file.url

          material
        }
      })
      .reduce { |mission, files| mission + files }

    # Make sure we return at least an empty list, in case there are no missions.
    if mission_files == nil
      mission_files = []
    end

    missions = MaterialFolder.create_virtual("missions", material_folder.id)
    missions.name = "Missions"
    missions.description = "Mission descriptions and other files"
    missions.files = mission_files

    training_files =
      # Get the trainings' files, and map it to the virtual entries.
      (self.trainings.map { |t|
        t.files.map { |f|
          material = Material.create_virtual(t, f)
          material.file = f
          material.filename = t.title + ": " + f.original_name
          material.filesize = f.file_file_size
          material.updated_at = f.file_updated_at
          material.url = f.file.url

          material
        }
      })
      .reduce { |training, files| training + files }

    # Make sure we return at least an empty list, in case there are no trainings.
    if training_files == nil
      training_files = []
    end

    trainings = MaterialFolder.create_virtual("trainings", material_folder.id)
    trainings.name = "Trainings"
    trainings.description = "Training descriptions and other files"
    trainings.files = training_files

    [missions, trainings]
  end
end
