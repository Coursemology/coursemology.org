class AsmReq < ActiveRecord::Base
  EPS = 1e-5

  attr_accessible :asm_id, :asm_type, :min_grade

  belongs_to :asm, polymorphic: true

  def satisfied?(user_course)
    # satisfied this asm or not?
    # what's the highest grade achieved in this assignment
    # query in submission the last submission by this user that has assignment id like that
    puts "#{id} check satisfy ASM REQ", self.to_json
    case asm
    when Training
      last_sbm = TrainingSubmission.find_by_student_id_and_training_id(user_course.user.id, asm_id)
    when Mission
      last_sbm = Submission.find_by_student_id_and_mission_id(user_course.user.id, asm_id)
    when Quiz
      last_sbm = QuizSubmission.find_by_student_id_and_quiz_id(user_course.user.id, asm_id)
    end

    puts 'last submission ', last_sbm.to_json

    if last_sbm
      final_grading = last_sbm.get_final_grading
      puts 'final grading ', final_grading.to_json
      if final_grading
        puts last_sbm.to_json
        puts final_grading.to_json
        percent = final_grading.total_grade * 100 / asm.max_grade
        return percent >= min_grade - EPS
      end
    end
    return false
  end
end
