class RenameCourseIdInFileUploads < ActiveRecord::Migration
  def change
    rename_column :file_uploads, :course_id, :owner_id
  end
end
