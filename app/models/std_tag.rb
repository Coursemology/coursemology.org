class StdTag < ActiveRecord::Base
  attr_accessible :exp, :std_course_id, :tag_id

  belongs_to :std_course, class_name: "UserCourse"
  belongs_to :tag

  before_create :init

  def get_completion_percentage
    return self.tag.max_exp == 0 ? 0 : self.exp * 100 / self.tag.max_exp
  end

  private
  def init
    self.exp ||= 0
  end
end
