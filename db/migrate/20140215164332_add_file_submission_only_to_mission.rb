class AddFileSubmissionOnlyToMission < ActiveRecord::Migration
  def change
    add_column :missions, :file_submission_only, :boolean, default: false
  end
end
