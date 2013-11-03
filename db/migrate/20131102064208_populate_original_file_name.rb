class PopulateOriginalFileName < ActiveRecord::Migration
  def up
    FileUpload.all.each do |file|
      unless file.original_name
        file.original_name = file.file_file_name
        file.save
      end
    end
  end

  def down
  end
end
