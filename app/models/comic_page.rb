class ComicPage < ActiveRecord::Base
  belongs_to :comic

  # is_tbc means that it is a 'To Be Continued page' and should not be displayed
  # if the next episode is available
  attr_accessible :page, :file, :comic, :is_tbc

  has_one :file, as: :owner, class_name: "FileUpload", dependent: :destroy


  def attach(file)
    existing_file = self.file

    file.owner = self
    # file.display_filename = existing_file.display_filename if existing_file
    if file.save and existing_file then
      existing_file.owner_type = nil
      existing_file.owner_id = nil
      existing_file.save
    end
  end
end
