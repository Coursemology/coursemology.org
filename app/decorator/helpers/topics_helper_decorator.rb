Forem::TopicsHelper.class_eval do
  def new_since_last_view_text(topic)
    if forem_user
      topic_view = topic.view_for(forem_user)
      forum_view = topic.forum.view_for(forem_user)

      if forum_view
        if topic_view.nil? && topic.created_at > forum_view.past_viewed_at
          content_tag :span, "New", :class => 'label label-info'
        end
      end
    end
  end
end