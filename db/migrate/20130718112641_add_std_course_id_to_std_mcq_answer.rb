class AddStdCourseIdToStdMcqAnswer < ActiveRecord::Migration
  def change
    add_column :std_mcq_answers, :std_course_id, :integer
    StdMcqAnswer.reset_column_information
    StdMcqAnswer.all.each do |std_mcq_ans|
      sbm_answer = std_mcq_ans.sbm_answers.first
      if sbm_answer && sbm_answer.sbm
        std_mcq_ans.std_course = sbm_answer.sbm.std_course
        std_mcq_ans.save
      else
        puts std_mcq_ans.to_json
      end
    end
  end
end
