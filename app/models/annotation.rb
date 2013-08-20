class Annotation < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :annotable_id, :annotable_type, :text, :user_course_id, :line_start, :line_end, :updated_at
  include Commenting

  belongs_to :user_course
  belongs_to :annotable, polymorphic: true

  def commentable
    annotable
  end

  def get_code_lines
    code = annotable.code
    selected = code.split("\n")[line_start - 1, line_end - line_start + 1]
    if selected and selected.size > 0
      selected.join("\n")
    else
      self.destroy
      nil
    end
  end
end
