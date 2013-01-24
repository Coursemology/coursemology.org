class UserCourse < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :course_id, :exp, :role_id, :user_id, :level_id

  belongs_to :role
  belongs_to :user
  belongs_to :course
  belongs_to :level

  has_many :user_achievements
  has_many :user_titles
  has_many :user_rewards
  has_many :exp_transactions
  has_many :seen_stuff, class_name: "SeenByUser"

  has_many :submissions, foreign_key: "std_course_id"
  has_many :training_submissions, foreign_key: "std_course_id"
  has_many :quiz_submissions, foreign_key: "std_course_id"

  has_many :seen_missions, through: :seen_stuff, source: :obj, source_type: "Mission"
  has_many :seen_quizzes, through: :seen_stuff, source: :obj, source_type: "Quiz"
  has_many :seen_trainings, through: :seen_stuff, source: :obj, source_type: "Training"
  has_many :seen_announcements, through: :seen_stuff, source: :obj, source_type: "Announcement"
  has_many :seen_submissions, through: :seen_stuff, source: :obj, source_type: "Submission"
  has_many :seen_training_submissions, through: :seen_stuff, source: :obj, source_type: "TrainingSubmission"
  has_many :seen_quiz_submissions, through: :seen_stuff, source: :obj, source_type: "QuizSubmission"
  has_many :seen_notifications, through: :seen_stuff, source: :obj, source_type: "Notification"

  has_many :notifications, foreign_key: "target_course_id"

  has_many :std_tags, foreign_key: "std_course_id"

  def is_student?
    return self.role == Role.find_by_name('student')
  end

  def is_lecturer?
    return self.role == Role.find_by_name('lecturer')
  end

  def level_percentage
    if self.level
      return self.exp * 100 / self.level.exp_threshold
    end
    return 0
  end

  def get_missions
    # sort by ones that is still open, the ones that is closed
    missions = course.missions.opened.still_open.order(:close_at) +
      course.missions.closed
    if self.is_lecturer?
      missions = course.missions.future.order(:open_at) + missions
    end
    return missions
  end

  def get_unseen_missions
    return self.get_missions - self.seen_missions
  end

  def get_trainings
    trainings = course.trainings.opened.order("open_at DESC")
    if self.is_lecturer?
      trainings = course.trainings.future.order(:open_at) + trainings
    end
    return trainings
  end

  def get_unseen_trainings
    return self.get_trainings - self.seen_trainings
  end

  def get_announcements
    if self.is_lecturer?
      announcements = course.announcements.order("publish_at DESC")
    else
      announcements = course.announcements.published.order("publish_at DESC")
    end
    return announcements
  end

  def get_unseen_announcements
    return self.get_announcements - self.seen_announcements
  end

  def get_unseen_sbms
    if self.is_lecturer?
      all_sbms = course.submissions + course.training_submissions +
        course.quiz_submissions
      seen_sbms = seen_submissions + seen_training_submissions + seen_quiz_submissions
      return all_sbms - seen_sbms
    end
    return nil
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
        if self.level != lvl
          Activity.earned_smt(self, lvl)
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
      # verify if users will win achievement ach
      uach = UserAchievement.find_by_user_course_id_and_achievement_id(id, ach.id)
      if not uach
        # not earned yet, check this achievement
        puts "#{ach.fulfilled_conditions?(self)} #{ach.to_json}"
        if ach.fulfilled_conditions?(self)
          # assign the achievement to student
          uach = self.user_achievements.build
          uach.achievement = ach
          new_ach = true
          Activity.earned_smt(self, ach)
          Notification.earned_achievement(self, ach)
        end
      end
    end
    if new_ach
      # better save first so that other models can do the checking correctly.
      self.save
      self.update_achievements
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
end
