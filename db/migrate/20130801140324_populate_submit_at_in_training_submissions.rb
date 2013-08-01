class PopulateSubmitAtInTrainingSubmissions < ActiveRecord::Migration
  def up
    TrainingSubmission.all.each do |sub|
      unless sub.submit_at
        sub.update_attribute(:submit_at, sub.created_at)
      end
    end
  end

  def down
  end
end
