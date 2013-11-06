Forem::TopicsHelper.class_eval do
  def link_to_latest_post(topic)
    post = relevant_posts(topic).last
    text = "#{time_ago_in_words(post.created_at)} #{t("ago_by")} #{post.user}"
    link_to text, main_app.course_forum_topic_path(@course, post.topic.forum, post.topic, :anchor => "post-#{post.id}", :page => topic.last_page)
  end

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