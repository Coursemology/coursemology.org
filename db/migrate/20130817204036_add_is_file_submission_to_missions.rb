class AddIsFileSubmissionToMissions < ActiveRecord::Migration
  def change
    add_column :missions, :is_file_submission, :bool, default: false
  end
end
