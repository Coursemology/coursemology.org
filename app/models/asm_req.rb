class AsmReq < ActiveRecord::Base
  EPS = 1e-5
  acts_as_duplicable

  include AsRequirement

  attr_accessible :asm_id, :asm_type, :min_grade

  belongs_to :asm, polymorphic: true

  def satisfied?(user_course)
    # satisfied this asm or not?
    # what's the highest grade achieved in this assignment
    # query in submission the last submission by this user that has assignment id like that
    last_sbm = asm.submissions.find_by_std_course_id(user_course.id)

    if last_sbm
      final_grading = last_sbm.get_final_grading
      if final_grading && asm.max_grade
        return ((final_grading.grade || 0) * 100 / asm.max_grade) >= min_grade - EPS
      end
    end
    false
  end
end
