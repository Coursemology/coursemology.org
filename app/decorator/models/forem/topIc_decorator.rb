Forem::Topic.class_eval do
  acts_as_readable :on => :created_at

  def approve_user_and_posts

  end
end