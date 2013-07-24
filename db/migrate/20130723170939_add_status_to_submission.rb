class AddStatusToSubmission < ActiveRecord::Migration

  def change
    add_column :submissions, :status, :string

    Submission.reset_column_information
    Submission.all.each do |sub|
      if sub.submission_gradings.count > 0
        sub.update_attribute(:status,'graded')
      else
        sub.update_attribute(:status,'submitted')
      end
    end
  end
end
