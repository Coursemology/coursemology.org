class Course < ActiveRecord::Base
  acts_as_paranoid

  # default_scope where(:is_pending_deletion => false)

  attr_accessible :creator_id, :description, :logo_url, :title, :is_publish, :is_active, :is_open, :start_at, :end_at
  before_create :populate_preference
  after_create :create_materials_root

  belongs_to :creator, class_name: "User"

  has_many :missions,          dependent: :destroy
  has_many :announcements,     dependent: :destroy
  has_many :user_courses ,     dependent: :destroy
  has_many :trainings,         dependent: :destroy
  has_many :lesson_plan_entries, dependent: :destroy
  has_many :lesson_plan_milestones, dependent: :destroy
  has_one  :root_folder, dependent: :destroy, :conditions => { :parent_folder_id => nil }, class_name: "MaterialFolder"
  has_many :material_folders

  has_many :comics,            dependent: :destroy

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
  has_many :course_navbar_preferences, dependent: :destroy
  has_many :comment_topics,         dependent: :destroy
  has_many :mass_enrollment_emails, dependent: :destroy
  has_many :enroll_requests,        dependent: :destroy
  has_many :tutor_monitorings,      dependent: :destroy
  has_many :surveys,                dependent: :destroy
  has_many :forums,                 dependent: :destroy, class_name: 'ForumForum'
  has_many :tabs,                   dependent: :destroy
  has_many :pending_actions

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
    student_sidebar_items.where(display: true)
  end

  def mission_columns_display
    mission_columns.select {|pref| pref.display }
  end

  def student_sidebar_ranking
    self.course_preferences.other_sidebar_items.where("preferable_items.name = 'ranking'").first
  end
  def show_ranking?
    student_sidebar_ranking.display?
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

  def forum_paging_pref
    paging_pref('Forums')
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

  def customized_missions_title
    customized_title('missions')
  end

  def customized_trainings_title
    customized_title('trainings')
  end

  def customized_announcements_title
    customized_title('announcements')
  end

  def customized_submissions_title
    customized_title('submissions')
  end

  def customized_achievements_title
    customized_title('achievements')
  end

  def customized_leaderboard_title
    customized_title('leaderboard')
  end

  def customized_students_title
    customized_title('students')
  end

  def customized_surveys_title
    customized_title('surveys')
  end

  def customized_materials_title
    customized_title('materials')
  end

  def customized_lesson_plan_title
    customized_title('lesson_plan')
  end

  def customized_forums_title
    customized_title('forums')
  end

  def customized_comments_title
    customized_title('comments')
  end

  def customized_title(tab)
    self.course_navbar_preferences.find_by_item(tab).name
  end

  def customized_title_by_model(model_class)
    self.course_navbar_preferences.find_by_item(model_class.model_name.downcase.pluralize).name
  end

  def navbar_tabs(is_staff = false)
    tabs = self.course_navbar_preferences.where(is_enabled: true).order(:pos)
    is_staff ? tabs : tabs.where(is_displayed: true)
  end

  def populate_preference
    course_preferences.each do |pref|
      item = PreferableItem.find_by_id(pref.preferable_item_id)
      unless item
        CoursePreference.destroy(pref)
      end
    end

    PreferableItem.all.each do |item|
      cp = CoursePreference.find_by_course_id_and_preferable_item_id(self.id, item.id)
      unless cp
        pref = self.course_preferences.build
        pref.preferable_item = item
        pref.prefer_value = item.default_value
        pref.display = item.default_display
        pref.save
      end
    end

    course_navbar_preferences.each do |pref|
      if pref.navbar_prefereable_item
        item = NavbarPreferableItem.find_by_id(pref.navbar_prefereable_item_id)
        unless item
          CourseNavbarPreference.destroy(pref)
        end
      end
    end

    NavbarPreferableItem.all.each do |item|
      cp = CourseNavbarPreference.find_by_course_id_and_navbar_preferable_item_id(self.id, item.id)
      unless cp
        pref = self.course_navbar_preferences.build
        pref.navbar_preferable_item = item
        pref.name = item.name
        pref.item = item.item
        pref.navbar_link_type= item.navbar_link_type
        pref.is_displayed= item.is_displayed
        pref.is_enabled = item.is_enabled
        pref.link_to = item.link_to
        pref.pos = item.pos
        pref.save
      end
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

  # Note: this method returns entries in the closed interval
  # of from and to: i.e. entries starting at both from and to
  # are included. [from, to]
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

  def materials_virtual_entries
    mission_files =
        # Get the missions' files, and map it to the virtual entries.
        (self.missions.map { |m|
          m.files.map { |f|
            material = Material.create_virtual(m, f)
            material.file = f
            material.filename = m.title + ": " + f.display_filename
            material.filesize = f.file_file_size
            material.updated_at = f.file_updated_at
            material.url = f.file_url

            material
          }
        })
        .reduce { |mission, files| mission + files }

    # Make sure we return at least an empty list, in case there are no missions.
    if mission_files == nil
      mission_files = []
    end

    missions = MaterialFolder.create_virtual("missions", root_folder.id)
    missions.name = customized_title_by_model(Mission).pluralize
    missions.description = missions.name.singularize + " descriptions and other files"
    missions.files = mission_files

    training_files =
        # Get the trainings' files, and map it to the virtual entries.
        (self.trainings.map { |t|
          t.files.map { |f|
            material = Material.create_virtual(t, f)
            material.file = f
            material.filename = t.title + ": " + f.display_filename
            material.filesize = f.file_file_size
            material.updated_at = f.file_updated_at
            material.url = f.file_url

            material
          }
        })
        .reduce { |training, files| training + files }

    # Make sure we return at least an empty list, in case there are no trainings.
    if training_files == nil
      training_files = []
    end

    trainings = MaterialFolder.create_virtual("trainings", root_folder.id)
    trainings.name = customized_title_by_model(Training).pluralize
    trainings.description = trainings.name + " descriptions and other files"
    trainings.files = training_files

    [missions, trainings]
  end

  def self.search(search)
    search_condition = "%" + search.downcase + "%"
    #User.where('lower(name) LIKE ?', search_condition)
    Course.includes(:creator).where(['lower(title) LIKE ? or lower(users.name) LIKE ?', search_condition, search_condition])
    #find(:all, :conditions => ['lower(name) LIKE ? OR lower(email) dLIKE ?', search_condition, search_condition])
  end

  def training_tabs
    tabs.where(owner_type: Training.to_s)
  end

  def mission_tabs
    tabs.where(owner_type: Mission.to_s)
  end

  def accessible_comics(user_course)
    comics.select {|comic| comic.can_view?(user_course)}
  end
end
