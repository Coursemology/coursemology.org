Forem::SubscriptionMailer.class_eval do
  def new_topic(topic_id, subscriber_id)
    # only pass id to make it easier to send emails using resque
    @topic = Forem::Topic.find(topic_id)
    @user = Forem.user_class.find(subscriber_id)

    mail(:to => @user.email, :subject => I18n.t('forem.topic.received_new_topic'))
  end
end