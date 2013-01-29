class CourseAbility
  include CanCan::Ability

  # checkout:
  # https://github.com/ryanb/cancan/wiki/Changing-Defaults
  # https://github.com/ryanb/cancan/wiki/Accessing-request-data
  def initialize(user_course)
    # user_course ||= UserCourse.new

    if user_course.is_lecturer?
      # this is enough since all resources are loaded related to
      # the current course
      can :manage, :all
      can :populate, Level
      return
    end

    can :read, [Course, UserCourse]
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
    can :new, EnrollRequest

    if user_course.is_student?
      puts "Guest rules"
      can :manage, [Submission, TrainingSubmission, QuizSubmission], std_course_id: user_course.id
      can :manage, [StdAnswer, StdMcqAnswer], student_id: user_course.user.id
    end
  end
end
