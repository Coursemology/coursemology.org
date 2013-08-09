class TutorialGroup < ActiveRecord::Base
  attr_accessible :course_id, :std_course_id, :tut_course_id

  belongs_to :course
  belongs_to :std_course, class_name: "UserCourse"
  belongs_to :tut_course, class_name: "UserCourse"

  validates :std_course_id, presence: true
  validates :tut_course_id, presence: true

  before_destroy :unsubscribe_comments
  before_create :subscribe_comments

  def unsubscribe_comments
    #unsubscribe everything related to this student
    topics = (std_course.std_answers + std_course.std_coding_answers).select { |sa| sa.comments.count > 0}
    topics.each do |topic|
      CommentSubscription.unsubscribe(topic, tut_course)
    end
  end

  def subscribe_comments
    topics = (std_course.std_answers + std_course.std_coding_answers).select { |sa| sa.comments.count > 0}
    topics.each do |topic|
      CommentSubscription.subscribe(topic, tut_course)
    end
  end

end
