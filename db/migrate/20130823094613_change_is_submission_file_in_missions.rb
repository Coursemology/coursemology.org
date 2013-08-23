class ChangeIsSubmissionFileInMissions < ActiveRecord::Migration
  def up
    change_column :missions, :is_file_submission, :boolean
  end

  def down
  end
end
