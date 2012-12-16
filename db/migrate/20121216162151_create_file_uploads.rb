class CreateFileUploads < ActiveRecord::Migration
  def change
    create_table :file_uploads do |t|
      t.integer :course_id
      t.integer :creator_id

      t.timestamps
    end
  end
end
