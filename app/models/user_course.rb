class UserCourse < ActiveRecord::Base
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

  has_many :seen_missions, through: :seen_stuff, source: :obj, source_type: "Mission"

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
    missions = course.missions.opened.still_open.order(:close_at) +
      course.missions.closed
    if self.is_lecturer?
      missions = course.missions.future.order(:open_at) + missions
    end
    return missions
  end

  def get_unseen_missions
    all = self.get_missions
    return all - self.seen_missions
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

    self.exp = 0
    self.exp_transactions.each do |expt|
      self.exp += expt.exp
    end

    self.course.levels.each do |lvl|
      # now: level = first level that is beyonds user's exp
      # how level is calculated must be given more thought
      if lvl.exp_threshold > self.exp
        self.level = lvl
        break
      end
    end
    self.save
    self.update_achievements
  end

  def update_achievements
    new_ach = false
    self.course.achievements.each do |ach|
      # verify if users will win achievement ach
      uach = UserAchievement.find_by_user_course_id_and_achievement_id(id, ach.id)
      if not uach
        # not earned yet, check this achievement
        if ach.fulfilled_conditions?(self)
          # assign the achievement to student
          uach = self.user_achievements.build
          uach.achievement = ach
          new_ach = true
        end
      end
    end
    if new_ach
      # better save first so that other models can do the checking correctly.
      self.save
      self.update_achievements
    end
  end
end
