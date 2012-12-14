class RenameSubmissionToSbmIdTypeInSubmissionGrading < ActiveRecord::Migration
  def change
    rename_column :submission_gradings, :submission_id, :sbm_id
    add_column :submission_gradings, :sbm_type, :string
  end
end
