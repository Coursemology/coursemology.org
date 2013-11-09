Forem::Post.class_eval do
  acts_as_votable

  def approve_user

  end

  def owner_or_admin?(other_user)
    user == other_user
  end
end