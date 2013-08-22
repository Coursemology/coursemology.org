class CommentTopic < ActiveRecord::Base
  default_scope { order("last_commented_at DESC") }

  attr_accessible :course_id, :last_commented_at, :permalink, :topic_id, :topic_type

  belongs_to :topic, polymorphic: true
  belongs_to :course

  has_many :comments
  has_many :comment_subscriptions, dependent: :destroy

  def comments_json(curr_user_course = nil, brief = false)
    responds = []

    self.comments.each do |c|
      puts curr_user_course.to_json
      edit  = false
      if curr_user_course and (curr_user_course.is_staff? || curr_user_course == c.user_course)
        edit = true
      end
      resp = c.as_json
      resp[:edit] = edit
      responds.append(resp)
    end

    sum = self.comments.count
    brief_resp = []
    if brief and sum > 5
      brief_resp << responds[0]
      brief_resp << { h: sum - 3 }
      brief_resp << responds[sum - 2]
      brief_resp << responds[sum - 1]
      return brief_resp
    end
    responds
  end

end
