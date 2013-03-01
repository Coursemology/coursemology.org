class CourseAbility
  include CanCan::Ability

  # checkout:
  # https://github.com/ryanb/cancan/wiki/Changing-Defaults
  # https://github.com/ryanb/cancan/wiki/Accessing-request-data
  def initialize(user, user_course)
    user ||= User.new
    user_course ||= UserCourse.new

    can :read, Course
    can :new, EnrollRequest

    if user_course.is_lecturer? || user.is_admin?
      # this is enough since all resources are loaded related to
      # the current course
      can :manage, :all
      can :populate, Level
      can :see_all, [Submission, TrainingSubmission, QuizSubmission]
      can :view_stat, [Mission, Training]
      can :participate, Course
      return
    end

    if user_course.is_student?
      can :participate, Course
      can :read, UserCourse
      can :read, Announcement, Announcement.published do |ann|
        ann.publish_at <= Time.now
      end
      can :read, Mission, Mission.opened do |mission|
        mission.open_at <= Time.now
      end
      can :read, Quiz, Quiz.opened do |quiz|
        quiz.open_at <= Time.now
      end
      can :read, Training, Training.opened do |training|
        training.open_at <= Time.now
      end

      can :read, Tag
      can :read, [Level, Achievement, Title, Reward]
      can :students, Course

      can :manage, [Submission, TrainingSubmission, QuizSubmission], std_course_id: user_course.id
      can :manage, [StdAnswer, StdMcqAnswer], student_id: user_course.user.id

      cannot :see_all, [Submission, TrainingSubmission, QuizSubmission]
    end
  end
end
