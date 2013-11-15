Forem::Topic.class_eval do
  acts_as_readable :on => :last_post_at

  def approve_user_and_posts

  end
end