class AddOwnerTypeToFileUploads < ActiveRecord::Migration
  def change
    add_column :file_uploads, :owner_type, :string

    FileUpload.update_all owner_type: 'Course'
  end
end
