class AddStdCourseIdToStdCodingAnswer < ActiveRecord::Migration
  def change
    add_column :std_coding_answers, :std_course_id, :integer
    StdCodingAnswer.reset_column_information
    StdCodingAnswer.all.each do |std_coding_ans|
      sbm_answer = std_coding_ans.sbm_answers.first
      if sbm_answer && sbm_answer.sbm
        std_coding_ans.std_course = sbm_answer.sbm.std_course
        std_coding_ans.save
      else
        puts std_coding_ans.to_json
      end
    end
  end
end
