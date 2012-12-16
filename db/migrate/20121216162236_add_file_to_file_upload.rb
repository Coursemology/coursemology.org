class AddFileToFileUpload < ActiveRecord::Migration
  def change
    add_attachment :file_uploads, :file
  end
end
