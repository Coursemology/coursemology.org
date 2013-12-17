class AddCopyUrlToFileUploads < ActiveRecord::Migration
  def change
    add_column :file_uploads, :copy_url, :string
  end
end
