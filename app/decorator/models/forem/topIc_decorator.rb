Forem::Topic.class_eval do
  acts_as_readable :on => :created_at

  after_save :email_category_subscribers, :if => Proc.new { |p| !p.notified? }
  def approve_user_and_posts

  end

  def email_category_subscribers
    self.forum.category.category_subscriptions.includes(:subscriber).find_each do |subscription|
      puts subscription.subscriber
      puts id
      subscription.send_notification(id) if subscription.subscriber != user
    end
    update_attribute(:notified, true)
  end
end