Forem::SubscriptionMailer.class_eval do
  def new_topic(topic_id, subscriber_id)
    # only pass id to make it easier to send emails using resque
    @topic = Forem::Topic.find(topic_id)
    @user = Forem.user_class.find(subscriber_id)

    @forum = @topic.forum
    @course = Course.find(@forum.category.id)
    @post = @topic.posts.first
    mail(:to => @user.email, :subject => @course.title + ': ' + I18n.t('forem.topic.received_new_topic'), :content_type => "text/html")
  end

  def new_post(post_id, subscriber_id)
    # only pass id to make it easier to send emails using resque
    @post = Forem::Post.find(post_id)
    @topic = @post.topic
    @first_post = @topic.posts.first
    @forum = @topic.forum

    @user = Forem.user_class.find(subscriber_id)
    @course = Course.find(@forum.category.id)

    mail(:to => @user.email, :subject => @course.title + ': ' + I18n.t('forem.topic.received_new_post'), :content_type => "text/html")
  end

  def digest(posts, user, course)
    posts.each do |post|
      puts post.text
      puts post.topic.subject
      puts post.created_at
    end
    mail(:to => user.email, :subject => course.title)
  end
end