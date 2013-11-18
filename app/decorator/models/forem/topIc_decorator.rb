Forem::Topic.class_eval do
  acts_as_readable :on => :last_post_at

  def approve_user_and_posts

  end

  def email_category_subscribers
    self.forum.category.category_subscriptions.includes(:subscriber).find_each do |subscription|
      subscription.send_notification(id) if subscription.subscriber != user
    end
    update_attribute(:notified, true)
  end
end