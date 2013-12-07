module Forums::ForumsHelper
  def topic_latest_post_path(course, forum, topic)
    course_forum_topic_path(course, forum, topic, anchor: "post-#{topic.posts.last.id}")
  end
end
