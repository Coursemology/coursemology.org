class Material < ActiveRecord::Base
  belongs_to :creator, class_name: "User"
  belongs_to :folder, class_name: "MaterialFolder"
  has_one :file, as: :owner, class_name: "FileUpload", dependent: :destroy

  attr_accessible :folder, :description, :filename
  after_save :save_file

  def save_file
    self.file.save
  end

  def filename
    self.file.original_name || self.file.file_file_name
  end
  
  def filename=(filename)
    self.file.original_name = filename
  end

  def filesize
    self.file.file_file_size
  end

  # Attaches the given file to this material; if an existing file is linked, the
  # link is broken.
  def attach(file)
    existing_file = self.file

    file.owner_id = self.id
    file.owner_type = self.class
    if file.save and existing_file then
      existing_file.owner_type = nil
      existing_file.owner_id = nil
      existing_file.save
    end
  end
end
