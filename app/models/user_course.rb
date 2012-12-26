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

  def is_student?
    return self.role.name == 'student'
  end

  def is_lecturer?
    return self.role.name == 'lecturer'
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
    puts "UPDATE Achievement", self.course.achievements.size
    new_ach = false
    self.course.achievements.each do |ach|
      # verify if users will win achievement ach
      puts 'Test achievement', ach
      uach = UserAchievement.find_by_user_course_id_and_achievement_id(id, ach.id)
      puts 'UserAchievement', uach, uach.to_json
      if not uach
        # not earned yet, check this achievement
        if ach.fulfilled_conditions?(self)
          # assign the achievement to student
          uach = self.user_achievements.build
          uach.achievement = ach
          new_ach = true
          puts "#{self.user.name} earned #{ach.title}"
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
