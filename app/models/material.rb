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

  def attach(file)
    file.owner = self
    file.save
  end
end
