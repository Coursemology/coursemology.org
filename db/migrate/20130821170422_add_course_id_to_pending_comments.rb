class AddCourseIdToPendingComments < ActiveRecord::Migration
  def change
    add_column :pending_comments, :course_id, :integer
    add_index :pending_comments, :course_id

    PendingComments.all.each do |c|
      answer = c.answer
      if answer.class == Mcq
         c.course_id = answer.asm_qns.first.asm.course_id
      elsif answer.class == StdAnswer
        c.course_id = answer.std_course.course_id
      elsif answer.class == StdCodingAnswer
        c.course_id = answer.std_course.course_id
      end
      c.save
    end
  end
end
