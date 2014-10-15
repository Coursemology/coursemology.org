class Annotation < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :annotable_id, :annotable_type, :text, :user_course_id, :line_start, :line_end, :updated_at
  include Commenting

  belongs_to :user_course
  belongs_to :annotable, polymorphic: true

  after_create :notify_user

  def commentable
    annotable
  end

  def get_code_lines
    code = annotable.content
    selected = code.split("\n")[line_start - 1, line_end - line_start + 1]
    if selected and selected.size > 0
      selected.join("\n")
    else
      self.destroy
      nil
    end
  end

  def notify_user
    # TODO: fix the notify_user function
    # currently this method wouldn't find the correct users to notify, marking pending wouldn't work either
    # I think it can be resolved by adding the annotable to the CommentTopic list. However, need to avoid
    # it being removed (when comments count == 0, the topic is removed -- see CommentController#destroy)
    #assumption, we can only annotate coding question answer for now
    sbm = commentable.submission

    if sbm.assessment.published?
      to_notify = sbm.std_course == user_course ? user_course.get_staff_incharge : [sbm.std_course]
      to_notify.each do |uc|
        UserMailer.delay.new_annotation(uc.user, sbm, self)
      end
    end
  end
end
