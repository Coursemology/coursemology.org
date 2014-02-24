class AddIsPublicToFileUploads < ActiveRecord::Migration
  def change
    add_column :file_uploads, :is_public, :boolean, default: true
  end
end
