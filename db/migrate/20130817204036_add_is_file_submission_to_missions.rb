class AddIsFileSubmissionToMissions < ActiveRecord::Migration
  def change
    add_column :missions, :is_file_submission, :boolean, default: false
  end
end
