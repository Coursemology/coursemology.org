Forem::Forum.class_eval do
  def last_post_for(forem_user)
    last_visible_post(forem_user)
  end
end