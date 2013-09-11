class AddOriginalNameToFileUploads < ActiveRecord::Migration
  def change
    add_column :file_uploads, :original_name, :string
  end
end
