class AddExpToAnswerGradings < ActiveRecord::Migration
  def change
    add_column :answer_gradings, :exp, :integer

    AnswerGrading.all.each do |ag|
      sbm = ag.submission_grading.sbm

      if sbm.class == TrainingSubmission
        ag.exp =  sbm.training.exp * (ag.grade.to_f / sbm.training.max_grade.to_f)
        ag.save
      elsif sbm.class == Submission
        ag.exp =  sbm.mission.exp * (ag.grade.to_f / sbm.mission.max_grade.to_f)
        ag.save
      end
    end
  end
end
