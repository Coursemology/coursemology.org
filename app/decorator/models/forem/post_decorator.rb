Forem::Post.class_eval do
  acts_as_votable
  acts_as_readable :on => :created_at

  def approve_user

  end

  def owner_or_admin?(other_user)
    user == other_user
  end
end