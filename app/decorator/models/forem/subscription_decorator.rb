Forem::Subscription.class_eval do
  def send_notification(post_id)
    # overrides mailer delivery
  end
end