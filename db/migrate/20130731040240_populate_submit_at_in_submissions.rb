class PopulateSubmitAtInSubmissions < ActiveRecord::Migration
  def up
    Submission.all.each do |sub|
      unless sub.submit_at
        sub.update_attribute(:submit_at, sub.created_at)
      end
    end
  end

  def down
  end
end
