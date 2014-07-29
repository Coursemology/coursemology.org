class MailingJob < Struct.new(:course_id, :type, :type_id, :redirect_to, :reminder)
  def perform
    course = Course.find_by_id(course_id)
    if reminder
      mission_reminder(Assessment::Mission.find(type_id), course)
      return
    end
    case type
      when Announcement.to_s
        new_announcements(Announcement.find(type_id), course)
      when Assessment::Mission.to_s
        new_mission(Assessment::Mission.find(type_id), course)
      when Assessment::Training.to_s
        new_training(Assessment::Training.find(type_id), course)
      when MassEnrollmentEmail.to_s
        enrollment_invitations(MassEnrollmentEmail.where(course_id: course_id, signed_up: false), course)
      when ForumPost.to_s
        forum_notification(ForumPost.find(type_id), course)
      when 'ForumDigests'
        forum_digests
    end
  end

  def new_announcements(ann, course)
    course.user_courses.each do |uc|
      user = uc.user
      UserMailer.delay.new_announcement(user.name, ann, user.email, redirect_to, course.title)
    end
  end

  def new_mission(mission, course)
    course.user_courses.each do |uc|
      user = uc.user
      UserMailer.delay.new_mission(user.name , user.email, mission.title, course, redirect_to)
    end
  end

  def new_training(training, course)
    course.user_courses.each do |uc|
      user = uc.user
      UserMailer.delay.new_training(user.name , user.email, training.title, course, redirect_to)
    end
  end

  def enrollment_invitations(enrols, course)
    lecturer = User.find(type_id)
    enrols.each do |enrol|
      unless enrol.pending_email?
        next
      end
      enrol.generate_confirm_token
      url = redirect_to + "?_token="+ enrol.confirm_token
      delayed_job = UserMailer.delay.enrollment_invitation(enrol.email, enrol.name, lecturer.name, course.title, url)
      enrol.delayed_job_id = delayed_job.id
      enrol.pending_email = false
      enrol.save
    end
  end

  def mission_reminder(mission, course)
    submitted_std = mission.submissions.map {|sub| sub.std_course.user }
    all_std = course.user_courses.student(is_phantom: false).map {|uc| uc.user }

    students = []
    (all_std - submitted_std).each do |user|
      UserMailer.delay.mission_due(user, mission, course, redirect_to)
      students << {name: user.name, email: user.email}
    end

    if students.count > 0
      course.user_courses.staff.each do |staff|
        UserMailer.delay.mission_reminder_summary(students, mission, staff.user)
      end
    end
  end

  def forum_notification(post, course)

    # send out notifications for subscribers
    topic = post.topic
    forum = topic.forum
    ucs = []
    first = topic.posts.count == 1
    (forum.subscriptions + topic.subscriptions).each do |sub|
      uc = sub.user
      if ucs.include? uc
        next
      end
      ucs << uc
      if first
        UserMailer.delay.forum_new_topic(uc, topic, post, course)
      else
        UserMailer.delay.forum_new_post(uc, post, course)
      end
    end
  end

  private
  def forum_digests
    Course.all.each do |course|
      course_forum_digests(course)
    end
  end

  def course_forum_digests(course)
    # Build a post list for every forum
    yesterday = (Time.now.midnight - 1.day)..(Time.now.end_of_day - 1.day)
    digest_date = Time.now.midnight - 1.day
    forums = {}
    course.forums.each do |forum|
      forums[forum.id.to_s] = [forum,
                               forum.posts.where(created_at: yesterday). # all posts created yesterday, by topic and time.
                                   order('topic_id ASC', 'created_at ASC')]
    end

    # Iterate over every subscription, sending out only the forums where the user specified he wanted
    # daily digests by concatenating the arrays together
    last_subscription = ForumForumSubscription.where(forum_id: forums.keys). # TODO: only do digests
        reduce({ posts: [], user: nil }) do |posts, subscription|
      if (posts[:user] != subscription.user)
        # Send out the posts for the previous user
        UserMailer.delay.forum_digest(posts[:user], posts.posts, course, digest_date) if posts[:user] && (not posts[:posts].empty?)

        # Reset the accumulator
        posts[:posts] = []
        posts[:user] = subscription.user
      end

      posts[:posts] += forums[subscription.forum.id.to_s][1]
      posts
    end

    # Handle the last user accumulated.
    if last_subscription[:user] && (not last_subscription[:posts].empty?)
      UserMailer.delay.forum_digest(last_subscription[:user], last_subscription[:posts], course, digest_date)
    end
  end

end
