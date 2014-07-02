class AddUseUploadedPictureToUser < ActiveRecord::Migration
  def change
    add_column :users, :use_uploaded_picture, :boolean, default: false
  end
end
