class AddStatusToTrainingSubmissions < ActiveRecord::Migration
  def change
    add_column :training_submissions, :status, :string

    TrainingSubmission.all.each do |sbm|
      if sbm.done?
        sbm.set_graded
      else
        sbm.set_submitted(nil, false)
      end
    end
  end
end
