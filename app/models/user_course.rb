class UserCourse < ActiveRecord::Base
  acts_as_paranoid

  include Rails.application.routes.url_helpers

  attr_accessible :course_id, :exp, :role_id, :user_id, :level_id, :is_phantom, :last_active_time

  before_create :init
  after_create  :notify_student

  scope :lecturer, where(:role_id => Role.lecturer.first)
  scope :tutor, where(:role_id => Role.tutor.first)
  scope :student, where(:role_id => Role.student.first)
  scope :real_students, where(:role_id => Role.student.first, is_phantom: false)
  scope :active_last_week, where("last_active_time > ?", (Time.now - 7.days))

  scope :shared, where(:role_id => Role.shared.first)
  scope :staff, where(:role_id => [Role.lecturer.first, Role.tutor.first]).
      joins('LEFT JOIN users on user_courses.user_id = users.id').
      order('lower(users.name) ASC')
  scope :top_achievements,
        joins('LEFT JOIN user_achievements ON user_courses.id=user_achievements.user_course_id')
        .select('user_courses.*, count(user_achievements.id) as ach_count, max(user_achievements.created_at) as ach_last_updated')
        .group('user_courses.id')
        .order('ach_count DESC, ach_last_updated ASC, id ASC')

  after_create :fetch_name

  belongs_to :role
  belongs_to :user
  belongs_to :course
  belongs_to :level

  has_many :user_achievements, dependent: :destroy
  has_many :user_titles
  has_many :user_rewards
  has_many :exp_transactions, dependent: :destroy
  has_many :seen_stuff, class_name: "SeenByUser"
  has_many :comments, dependent: :destroy
  has_many :comment_subscriptions, dependent: :destroy
  has_many :comment_topics, through: :comment_subscriptions

  has_many :submissions, foreign_key: "std_course_id", dependent: :destroy
  has_many :training_submissions, foreign_key: "std_course_id", dependent: :destroy

  has_many :std_answers, foreign_key: "std_course_id", dependent: :destroy
  has_many :std_coding_answers, foreign_key: "std_course_id", dependent: :destroy

  has_many :seen_missions, through: :seen_stuff, source: :obj, source_type: "Mission"
  has_many :seen_trainings, through: :seen_stuff, source: :obj, source_type: "Training"
  has_many :seen_announcements, through: :seen_stuff, source: :obj, source_type: "Announcement"
  has_many :seen_submissions, through: :seen_stuff, source: :obj, source_type: "Submission"
  has_many :seen_training_submissions, through: :seen_stuff, source: :obj, source_type: "TrainingSubmission"
  has_many :seen_materials, through: :seen_stuff, source: :obj, source_type: "Material"
  has_many :seen_notifications, through: :seen_stuff, source: :obj, source_type: "Notification"
  has_many :seen_comics, through: :seen_stuff, source: :obj, source_type: "Comic"

  has_many :notifications, foreign_key: "target_course_id"

  has_many :std_tags, foreign_key: "std_course_id", dependent: :destroy
  has_many :std_group_courses, class_name: "TutorialGroup",foreign_key:"tut_course_id", dependent: :destroy
  has_many :tut_group_courses, class_name: "TutorialGroup",foreign_key:"std_course_id", dependent: :destroy
  has_many :submission_gradings, foreign_key: "grader_course_id"
  has_many :std_courses, through: :std_group_courses
  has_many :tut_courses, through: :tut_group_courses
  has_many :activities, foreign_key: "actor_course_id", dependent: :destroy
  has_many :pending_actions, dependent: :destroy

  default_scope includes(:course)

  def is_student?
    self.role == Role.find_by_name('student')
  end

  def is_lecturer?
    self.role == Role.find_by_name('lecturer')
  end

  def is_ta?
    self.role == Role.find_by_name('ta')
  end

  def is_staff?
    self.is_ta? || self.is_lecturer?
  end

  def is_creator?
    self.user and self.user == self.course.creator
  end

  def level_percentage
    if self.level
      threshold = self.level.next_level.exp_threshold
      return threshold == 0? 0 : self.exp * 100 / self.level.next_level.exp_threshold
    end
    0
  end

  def get_seen_sbms
    seen_submissions + seen_training_submissions
  end

  def get_unseen_notifications
    self.notifications - self.seen_notifications
  end

  def mark_as_seen(obj)
    obj = obj.to_a if (obj.is_a?(Enumerable) && (not obj.is_a?(Array)))
    obj = [obj] unless obj.is_a?(Enumerable)
    mark_as_seen_array(obj)
  end

  def update_exp_and_level_async
    Thread.new {
      update_exp_and_level
    }
  end

  def update_exp_and_level
    # recalculate the EXP and level of the student (user)
    # find all submission_grading and calculate the score
    # get all (final grading)
    puts "UPDATE EXP AND LEVEL OF STUDENT", self.to_json

    self.exp = self.exp_transactions.sum(&:exp)
    self.exp = self.exp >= 0 ? self.exp : 0

    new_level = nil
    self.course.levels.each do |lvl|
      if lvl.exp_threshold <= self.exp
        new_level = lvl
      else
        break
      end
    end

    if new_level && self.level != new_level && self.is_student?
      self.level = new_level
      unless self.is_phantom?
        Activity.reached_lvl(self, new_level)
        Notification.leveledup(self, new_level)
      end
    end

    self.exp_updated_at = Time.now
    self.save
    self.update_achievements
    ActionController::Base.new.expire_fragment("sidebar/#{course.id}/uc/#{self.id}")
  end

  def update_achievements
    puts "CHECK ACHIEVEMENT ", self.to_json
    new_ach = false
    self.course.achievements.each do |ach|
      new_ach ||= self.check_achievement(ach)
    end
    if new_ach
      self.update_achievements
    end
  end

  def check_achievement(ach, should_notify=true)
    # verify if users will win achievement ach
    uach = UserAchievement.find_by_user_course_id_and_achievement_id(id, ach.id)
    fulfilled = false
    if not uach
      # not earned yet, check this achievement
      if ach.fulfilled_conditions?(self)
        # assign the achievement to student
        fulfilled = true
        self.give_achievement(ach, should_notify)
      end
    end
    fulfilled
  end

  def give_achievement(ach, should_notify=true)
    uach = UserAchievement.find_by_user_course_id_and_achievement_id(id, ach.id)
    unless uach
      uach = self.user_achievements.build
      uach.achievement = ach
      if should_notify && self.is_student? && !self.is_phantom?
        Activity.earned_smt(self, ach)
        Notification.earned_achievement(self, ach)
      end
      self.save
    end
  end

  def remove_achievement(ach)
    uach = UserAchievement.find_by_user_course_id_and_achievement_id(id, ach.id)
    if uach
      uach.destroy
    end
  end

  def create_all_std_tags
    # in case there are tags that are not associated with the student, create new std_tag record
    self.course.tags.each do |tag|
      std_tag = self.std_tags.find_by_tag_id(tag.id)
      if not std_tag
        self.std_tags.build( { tag_id: tag.id, exp: 0 } )
      end
    end
    self.save
  end

  def init
    self.exp = 0
    self.level = self.course.levels.find_by_level(0)
  end

  def manual_exp_award(user_course_id, exp, reason)
    user_course = self.course.user_courses.find(user_course_id)
    puts user_course, exp, reason
    exp_transaction = ExpTransaction.new
    exp_transaction.exp = exp
    exp_transaction.giver = self.user
    exp_transaction.user_course = user_course
    exp_transaction.reason = reason
    exp_transaction.is_valid = true
    exp_transaction.save
    user_course.update_exp_and_level_async
  end

  def get_staff_incharge
    tutor_courses = get_my_tutors
    if tutor_courses.size == 0
      tutor_courses = self.course.lect_courses
    end
    tutor_courses
  end

  def get_my_tutors
    #self.tut_courses
    Rails.cache.fetch("my_tutor_#{id}") { self.tut_courses }
  end

  def get_my_tutor_name
    tut_course =  self.get_my_tutors.first
    if tut_course
      tut_course.name
    else
      'Unassigned!'
    end
  end

  def get_my_stds
    if self.std_courses.size > 0
      self.std_courses
    elsif self.is_lecturer?
      self.get_all_stds
    else
      []
    end
  end

  def get_all_stds
    UserCourse.where(course_id: self.course_id).student
  end

  def get_path
    course_user_course_path(self.course, self)
  end

  def fetch_name
    self.name = user.name
    self.save
  end

  def notify_student
    if self.course.email_notify_enabled? PreferableItem.new_student
      if self.role.name == 'student'
        UserMailer.delay.new_student(self.user, self.course)
      end
    end
  end

  def leaderboard_achievements
    self.user_achievements.order('created_at desc').first(6)
  end

private
  # @param [Array] An array of objects which will be marked as seen
  def mark_as_seen_array(objs)
    return if objs.empty?

    # Find the asymmetric difference between the input array and the stuff we already have marked seen.
    seen = (self.seen_stuff.where(obj_id: objs, obj_type: objs[0].class.to_s).map {|obj|
      obj.obj_id
    }).to_set
    new = (objs.map {|obj|
      obj.id
    }).to_set - seen

    # Then store all the new IDs as
    SeenByUser.transaction do
      new.each do |obj|
        s = self.seen_stuff.build()
        s.obj_type = objs[0].class.to_s
        s.obj_id = obj
        s.save
      end
    end
  end
end
