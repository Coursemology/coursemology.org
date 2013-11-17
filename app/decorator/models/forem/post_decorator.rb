Forem::Post.class_eval do
  acts_as_votable
  acts_as_readable :on => :created_at
  after_create :email_category_subscribers


  def approve_user

  end

  def owner_or_admin?(other_user)
    user == other_user
  end

  def email_category_subscribers
    self.topic.forum.category.category_subscriptions.includes(:subscriber).find_each do |subscription|
      subscription.send_notification(id) if subscription.subscriber != user
    end
  end

end