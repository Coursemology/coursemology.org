class CourseAbility
  include CanCan::Ability

  # checkout:
  # https://github.com/ryanb/cancan/wiki/Changing-Defaults
  # https://github.com/ryanb/cancan/wiki/Accessing-request-data

=begin
    TODO:
        The right way for authorization here should be:
        First authorize staff
        Then authorize lecturer
        Then authorize admin(manage all)
=end
  def initialize(user, user_course)
    user ||= User.new
    user_course ||= UserCourse.new

    can :read, Course
    can :new, EnrollRequest

    if !user.persisted?
      # not logged in user
      cannot :read, [Mission, Training]
    end

    if user.is_lecturer? || user.is_admin?
      can :ask_for_share, Course
      can :create, Course
      user.user_courses.lecturer.each do |uc|
        can :manage, uc.course
      end
    end

    if user_course.role == Role.shared.first || user.is_admin?
      can :share, Course
      can :participate, Course
      can :duplicate, Course
      can :read, [Mission, Training]
      can :view_detail, [Mission, Training]
      can :read, Tag
      can :read, [Level, Achievement, Title, Reward]
      can :students, Course
    end

    if user.is_admin?  || user_course.is_staff?
      # this is enough since all resources are loaded related to
      # the current course
      can :manage, :all
      can :see_all, [Submission, TrainingSubmission, Level]
      can :view_stat, [Mission, Training]
      can :view_detail, [Mission, Training, Survey]
      can :participate, Course
      can :duplicate, Course
      can :award_points, UserCourse
      can :see, :pending_grading
      can :see, :pending_comments
      can :unsubmit, Submission
      can :view, :staff_leaderboard

      cannot :modify, TrainingSubmission
    end

    if user.is_admin? || user_course.is_creator?
      can :destroy, Course
    end

    if user_course.is_lecturer? && !user.is_admin?
      cannot :manage, :user
    end

    if user_course.is_ta? && !user.is_admin?
      cannot :manage, :user
      cannot :manage, :course_preference
      cannot :manage, :staff
      cannot :approve, EnrollRequest
      cannot :destroy, Course
      cannot :manage, :course_admin
    end

    if user.is_admin?  || user_course.is_staff?
      return
    end

    if user_course.is_student?
      can :participate, Course
      can :read, UserCourse
      can :read, Announcement, Announcement.published do |ann|
        ann.publish_at <= Time.now
      end

      # Materials: The file is accessible to students if the student uploaded
      # the file, or course staff uploaded the file.
      can :read, MaterialFolder, ['open_at <= ? OR open_at IS NULL', DateTime.now] do |folder|
        folder.open_at == nil || folder.open_at <= DateTime.now
      end
      can :upload, MaterialFolder, [
        'can_student_upload = ? AND \
         (open_at <= ? OR open_at IS NULL) AND \
         (close_at >= ? OR close_at IS NULL)', true, DateTime.now, DateTime.now] do |folder|
        folder.can_student_upload? && folder.is_open?
      end
      can :manage, Material, :file => { :creator_id => user.id }
      can :read, Material, :file => {
        :creator_id => UserCourse.staff.where(:course_id => user_course.course).pluck(:user_id) }

      # Forums: The posts are accessible if they are not marked hidden, regardless of whether they
      # made the thread or not. Hiding is an admin function.
      #
      # Students can delete their own posts and threads.
      can :read, ForumForum
      can :create, ForumTopic
      can :read, ForumTopic, hidden: false
      can :reply, ForumTopic, locked: false
      can :destroy, ForumTopic, locked: false, author: user_course
      can :set_answer, ForumTopic, locked: false, author: user_course
      can :read, ForumPost
      can :create, ForumPost
      can :set_vote, ForumPost
      can :destroy, ForumPost, author: user_course

      # Students can edit their own posts
      can :edit, ForumPost, author: user_course
      can :update, ForumPost, author: user_course

      # Students cannot make topics sticky nor announcements, they also cannot lock and make posts hidden
      cannot :set_sticky, ForumTopic
      cannot :set_announcement, ForumTopic
      cannot :set_lock, ForumTopic
      cannot :set_hidden, ForumTopic

      can :read, [LessonPlanEntry]
      can :read, [LessonPlanMilestone], is_publish: true

      can :read, [Mission, Training, Survey], publish: true

      can :read, [Mcq, Question, CodingQuestion]

      can :read, Tag
      can :read, [Achievement, Title, Reward]
      can :students, Course
      can :access_denied, Mission
      can :access_denied, Training

      can :manage, [Submission, TrainingSubmission, Annotation, Comment], std_course_id: user_course.id
      can :manage, SurveySubmission, user_course_id: user_course.id
      can :manage, SurveyMrqAnswer, user_course_id: user_course.id
      can :manage, [StdAnswer, StdMcqAnswer, StdCodingAnswer], student_id: user_course.user.id
      can :manage, ExpTransaction, user_course_id: user_course.id

      cannot :modify, TrainingSubmission

      cannot :see_all, [Submission, TrainingSubmission]
    end
  end
end
