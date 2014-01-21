module Forums::ForumsHelper
  def topic_latest_post_path(course, forum, topic)
    course_forum_topic_path(course, forum, topic, anchor: "post-#{topic.posts.last.id}")
  end

  # Prepend the given post title with a RE: if it does not already have one.
  # @param title The title to make into a reply.
  # @returns string
  def replize_title(title)
    if /^re:/i =~ title
      title
    else
      'RE: ' + title
    end
  end
end
