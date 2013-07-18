class AddStdCourseIdToStdAnswer < ActiveRecord::Migration
  def change
    add_column :std_answers, :std_course_id, :integer
    StdAnswer.reset_column_information
    StdAnswer.all.each do |std_ans|
      sbm_answer = std_ans.sbm_answers.first
      if sbm_answer && sbm_answer.sbm
        std_ans.std_course = sbm_answer.sbm.std_course
        std_ans.save
      else
        puts std_ans.to_json
      end
    end
  end
end
