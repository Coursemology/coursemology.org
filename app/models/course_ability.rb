class CourseAbility  < Ability
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
    super(user)
    user ||= User.new
    user_course ||= UserCourse.new
    course = user_course.course

    can :read, course
    can :new, EnrollRequest
    can :read, UserCourse
    unless user.persisted?
      # not logged in user
      cannot :read, [Assessment::Mission, Assessment::Training]
    end

    if user.is_lecturer?
      can :ask_for_share, Course
      can :create, Course
      user.user_courses.lecturer.includes(:course).each do |uc|
        can :manage, uc.course
      end
    end

    if user_course.is_shared?
      can :share, Course
      can :participate, Course
      can :duplicate, Course
      can :read, [Assessment::Mission, Assessment::Training]
      can :view_detail, [Assessment::Mission, Assessment::Training]
      can :read, Tag
      can :students, Course
    end

    if user.is_admin?  || user_course.is_staff?
      # this is enough since all resources are loaded related to
      # the current course
      can :manage, :all
      # can :manage, [Assessment, Assessment::Training, Assessment::Mission, Assessment::Submission, Assessment::Grading]
      # can :manage, [Assessment::Question, Assessment::McqQuestion, Assessment::CodingQuestion]
      # can :manage, [Assessment::Answer, Assessment::McqAnswer, Assessment::CodingAnswer, Assessment::GeneralAnswer]
      # can :manage, [Level, Achievement, Tab, Announcement]
      # can :manage, [LessonPlanEntry, LessonPlanMilestone, MaterialFolder, Material]
      # can :manage, [Survey, ForumForum, ForumTopic]
      # can :manage, [Course, UserCourse, ExpTransaction]
      # can :manage, [Annotation, Comment]
      # can :manage, [TagGroup, Tag]
      # can :see, :pending_gradings
      # can :see, :pending_comments
      # can :view, :staff_leaderboard
      # can :manage, :forum_participation
      # can :manage, [EnrollRequest, MassEnrollmentEmail]

      cannot :modify, Assessment::Submission
      #TOFIX, this is just for english
      cannot :manage, TagGroup, name: "Uncategorized"
    end

    if user_course.is_lecturer? && !user.is_admin?
      cannot :manage, :user
    end

    if user_course.is_ta? && !user.is_admin?
      cannot :manage, :user
      cannot :manage, :course_preference
      cannot :manage, :staff
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
      can :subscribe, ForumForum
      can :unsubscribe, ForumForum
      can :create, ForumTopic
      can :create_topic, ForumForum, locked: false
      can :reply_topic, ForumTopic do |topic|
        !topic.locked? && !topic.forum.locked?
      end
      can :subscribe, ForumTopic
      can :unsubscribe, ForumTopic
      can :read, ForumTopic, hidden: false
      can :read, ForumTopic, author_id: user_course.id
      can :reply, ForumTopic, locked: false
      can [:edit, :update, :destroy], ForumTopic do |topic|
        !topic.locked? && topic.author == user_course && !topic.forum.locked?
      end
      can :set_answer, ForumPost do |post|
          post.topic.author == user_course && !post.topic.locked?
      end
      can :read, ForumPost
      can :create, ForumPost
      can :set_vote, ForumPost

      # Students can edit their own posts
      can [:edit, :update, :destroy], ForumPost do |post|
        post.author == user_course && !post.topic.locked? && !post.topic.forum.locked?
      end


      # Students cannot make topics sticky nor announcements, they also cannot lock and make posts hidden
      cannot :set_sticky, ForumTopic
      cannot :set_announcement, ForumTopic
      cannot :set_lock, ForumTopic
      cannot :set_hidden, ForumTopic

      can :read, [LessonPlanEntry]
      can :read, [LessonPlanMilestone], is_publish: true

      can :read, Assessment, published: true
      can :access_denied, Assessment
      can :read, [Assessment::Mission, Assessment::Training], assessment: {published: true}
      can :read, Survey, publish: true

      # can :read, [Mcq, Question, CodingQuestion]

      can :read, Tag
      can :read, Achievement
      can :students, Course

      can :manage, [Assessment::Submission], std_course_id: user_course.id
      can :manage, [Annotation, Comment], user_course_id: user_course.id
      can :manage, SurveySubmission, user_course_id: user_course.id
      can :manage, SurveyMrqAnswer, user_course_id: user_course.id
      can :manage, Assessment::Answer, std_course_id: user_course.id
      can :read, Assessment::Grading, std_course_id: user_course.id
      can :read, ExpTransaction, user_course_id: user_course.id

      can :ignore, PendingAction, user_course: user_course

      can :read, Comic
      can :info, Comic

      cannot :modify, Assessment::Submission
      cannot :see_all, Assessment::Submission

      # students can see the guild leaderboard
      can :read, Guild
    end
  end
end
