class UserCourse < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :course_id, :exp, :role_id, :user_id, :level_id

  before_create :init

  scope :lecturer, where(:role_id => Role.lecturer.first)
  scope :student, where(:role_id => Role.student.first)
  scope :shared, where(:role_id => Role.shared.first)

  belongs_to :role
  belongs_to :user
  belongs_to :course
  belongs_to :level

  has_many :user_achievements
  has_many :user_titles
  has_many :user_rewards
  has_many :exp_transactions
  has_many :seen_stuff, class_name: "SeenByUser"
  has_many :comments

  has_many :submissions, foreign_key: "std_course_id"
  has_many :training_submissions, foreign_key: "std_course_id"
  has_many :quiz_submissions, foreign_key: "std_course_id"

  has_many :std_answers, foreign_key: "std_course_id"

  has_many :seen_missions, through: :seen_stuff, source: :obj, source_type: "Mission"
  has_many :seen_quizzes, through: :seen_stuff, source: :obj, source_type: "Quiz"
  has_many :seen_trainings, through: :seen_stuff, source: :obj, source_type: "Training"
  has_many :seen_announcements, through: :seen_stuff, source: :obj, source_type: "Announcement"
  has_many :seen_submissions, through: :seen_stuff, source: :obj, source_type: "Submission"
  has_many :seen_training_submissions, through: :seen_stuff, source: :obj, source_type: "TrainingSubmission"
  has_many :seen_quiz_submissions, through: :seen_stuff, source: :obj, source_type: "QuizSubmission"
  has_many :seen_notifications, through: :seen_stuff, source: :obj, source_type: "Notification"

  has_many :notifications, foreign_key: "target_course_id"

  has_many :std_tags, foreign_key: "std_course_id", dependent: :destroy
  has_many :std_courses, class_name: "TutorialGroup",foreign_key:"tut_course_id", dependent: :destroy
  has_many :tut_courses, class_name: "TutorialGroup",foreign_key:"std_course_id", dependent: :destroy

  def is_student?
    self.role == Role.find_by_name('student')
  end

  def is_lecturer?
    self.role == Role.find_by_name('lecturer')
  end

  def is_ta?
    self.role == Role.find_by_name('ta')
  end

  def is_stuff?
    self.is_ta? || self.is_lecturer?
  end

  def is_creator?
    self.user == self.course.creator
  end

  def level_percentage
    if self.level
      return self.exp * 100 / self.level.exp_threshold
    end
    return 0
  end

  def get_seen_sbms
    seen_sbms = seen_submissions + seen_training_submissions + seen_quiz_submissions
    return seen_sbms
  end

  def get_unseen_notifications
    return self.notifications - self.seen_notifications
  end

  def mark_as_seen(obj)
    s = self.seen_stuff.build()
    s.obj = obj
    s.save
  end

  def update_exp_and_level
    # recalculate the EXP and level of the student (user)
    # find all submission_grading and calculate the score
    # get all (final grading)
    puts "UPDATE EXP AND LEVEL OF STUDENT", self.to_json

    self.exp = self.exp_transactions.sum(&:exp)

    self.course.levels.each do |lvl|
      # now: level = first level that is beyonds user's exp
      # how level is calculated must be given more thought
      if lvl.exp_threshold > self.exp
        if self.level != lvl && lvl.level > 1
          Activity.earned_smt(self, lvl)
          Notification.leveledup(self, lvl)
        end
        self.level = lvl
        break
      end
    end
    self.save

    self.update_achievements
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

  def check_achievement(ach)
    # verify if users will win achievement ach
    uach = UserAchievement.find_by_user_course_id_and_achievement_id(id, ach.id)
    fulfilled = false
    if not uach
      # not earned yet, check this achievement
      puts "#{ach.fulfilled_conditions?(self)} #{ach.to_json}"
      if ach.fulfilled_conditions?(self)
        # assign the achievement to student
        fulfilled = true
        self.give_achievement(ach)
      end
    end
    return fulfilled
  end

  def give_achievement(ach)
    uach = UserAchievement.find_by_user_course_id_and_achievement_id(id, ach.id)
    if not uach
      uach = self.user_achievements.build
      uach.achievement = ach
      Activity.earned_smt(self, ach)
      Notification.earned_achievement(self, ach)
      self.save
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
    self.level = self.course.levels.find_by_level(1)
  end

  def manual_exp_award(user_course_id,exp,reason)
    user_course = self.course.user_courses.find(user_course_id)
    puts user_course, exp, reason
    exp_transaction = ExpTransaction.new
    exp_transaction.exp = exp
    exp_transaction.giver = self.user
    exp_transaction.user_course = user_course
    exp_transaction.reason = reason
    exp_transaction.is_valid = true
    exp_transaction.save
    user_course.update_exp_and_level
  end

  def get_my_tutors
    tutor_courses = self.tut_courses.map{|tg| tg.tut_course}
    if tutor_courses.size == 0
      tutor_courses = self.course.lect_courses
    end
    tutor_courses
  end
end
