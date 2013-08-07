class AddTotalExpToSubmissionGradings < ActiveRecord::Migration
  def change
    add_column :submission_gradings, :total_exp, :integer

    SubmissionGrading.all.each do |sg|
      if sg.grader_id
        sg.total_exp = sg.answer_gradings.sum(&:exp)
        sg.save
      end
    end
  end
end
